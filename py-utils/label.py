#!/usr/bin/env python3

import argparse
import csv
import os
import numpy as np
import pandas as pd
import random
import signal
import sys

from sklearn.externals import joblib
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import make_pipeline


def label(in_csv,
          label_classes,
          labels_are_mutually_exclusive,
          retrain_every_n,
          max_error_rate_for_bulk_review,
          error_rate_last_n,
          chunk_size,
          save_model,
          output_csv):

    get_df, get_label = get_helpers(labels_are_mutually_exclusive)
    df = get_df(output_csv, label_classes)
    unlabeled_texts = get_unlabeled_texts(in_csv, df)

    if not labels_are_mutually_exclusive:
        print('\nEnter label classes, i.e. "w[, d]", or "-" to clear labels\n')
    else:
        print('\nEnter label class, i.e. "w"\n')

    df, unlabeled_texts = single_review(df,
                                        unlabeled_texts,
                                        label_classes,
                                        retrain_every_n,
                                        error_rate_last_n,
                                        max_error_rate_for_bulk_review,
                                        save_model,
                                        output_csv)
    bulk_review(df, unlabeled_texts, label_classes, save_model, output_csv)
    return


def get_helpers(labels_are_mutually_exclusive):
    get_df = get_multi_df
    get_label = get_multi_label
    if labels_are_mutually_exclusive:
        get_df = get_single_df
        get_label = get_single_label
    return get_df, get_label


def get_unlabeled_texts(in_csv, df):
    with open(in_csv) as f:
        unlabeled_texts = set(f.read().splitlines()) - set(df.text)
    if not unlabeled_texts:
        print('All texts already labeled!')
        sys.exit(0)
    return unlabeled_texts


def single_review(df,
                  unlabeled_texts,
                  label_classes,
                  retrain_every_n,
                  error_rate_last_n,
                  max_error_rate_for_bulk_review,
                  save_model,
                  output_csv):
    model = None
    label_cols = get_label_cols(df)
    last_n_error = LastN(error_rate_last_n)
    while (last_n_error.rate() > max_error_rate_for_bulk_review):
        text_to_label, unlabeled_texts = \
            sample_and_remove_n(unlabeled_texts, 1)
        if model:
            pred = model.predict([text_to_label])[0]
            label = get_label(text_to_label, label_classes, pred)
            last_n_error.add(not np.array_equal(pred, label))
        else:
            label = get_label(text_to_label, label_classes)
        row = {'text': text_to_label}
        row.update(dict(zip(label_cols, label)))
        df = df.append(row, ignore_index=True)
        save(df, output_csv)
        if should_train_model(df, retrain_every_n):
            model = train(df.text, df[label_cols], save_model)
    return df, unlabeled_texts


def get_multi_df(output_csv, label_classes):
    colnames = label_classes + ['text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv, na_filter=False).drop_duplicates()
    assert set(df.columns).issubset(set(colnames))
    assert (set(df.columns) - set(['text'])).issubset(set(label_classes))
    df[label_classes] = df[label_classes].astype(int)
    return df.reindex(columns=colnames)


def get_multi_label(text, label_classes, preds=None):
    # NOTE: type '-' to clear all labels
    labels = [0] * len(label_classes)
    if preds is not None:
        labels = preds
    pred_str = ','.join(np.array(label_classes)[np.array(labels).astype(bool)])
    while (True):
        lbl = input(text + ' [%s]: ' % pred_str)
        if not lbl:
            return labels
        if lbl == '-':
            return [0] * len(label_classes)
        lbls = set([x.strip() for x in lbl.split(',')])
        if lbls.issubset(label_classes):
            labels = [0] * len(label_classes)
            for lbl in lbls:
                labels[label_classes.index(lbl)] = 1
            return labels


def get_single_df(output_csv, label_classes):
    colnames = ['label', 'text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv, na_filter=False).drop_duplicates()
    assert set(df.columns).issubset(set(colnames))
    assert set(df.label).issubset(set(label_classes))
    return df.reindex(columns=colnames)


def get_single_label(text, label_classes, pred=None):
    label = str(label_classes[0])
    if pred:
        label = str(pred)
    while (True):
        lbl = input(text + ' [%s]: ' % label)
        if not lbl:
            return label
        if lbl in label_classes:
            return lbl


def get_label_cols(df):
    cols = list(df.columns)
    cols.remove('text')
    return cols


class LastN(object):

    def __init__(self, n, init=True):
        self.a = [init] * n
        return

    def add(self, b):
        assert isinstance(b, bool)
        self.a.insert(0, b)
        self.a.pop()
        return

    def rate(self):
        return np.mean(np.array(self.a))


def should_train_model(df, retrain_every_n):
    nrow = len(df)
    if nrow <= retrain_every_n or nrow % retrain_every_n != 0:
        return False
    label_cols = get_label_cols(df)
    if len(label_cols) > 1:  # multilabel
        for label_col in label_cols:
            if not df[label_col].sum() > 1:
                return False
    return True


def sample_and_remove_n(superset, n):
    subset = random.sample(superset, min(n, len(superset)))
    if n == 1:
        subset = subset[0]
    return subset, superset - set(subset)


def save(df, output_csv):
    df = df.reindex(columns=get_label_cols(df) + ['text'])
    df.to_csv(output_csv, index=False, quoting=csv.QUOTE_NONNUMERIC)
    return


def train(X, y, save_model):
    p = make_pipeline(CountVectorizer(analyzer='char_wb',
                                      ngram_range=(2,4),
                                      stop_words='english',
                                      lowercase=True),
                      RandomForestClassifier(n_estimators=200))
    if y.shape[1] == 1:
        y = y.iloc[:, 0].ravel()
    p.fit(X, y)
    if save_model:
        joblib.dump(p, save_model)
    return p


def get_labels_in_bulk(get_label, label_classes, df_to_label):
    edit_indices = get_edit_indices(df_to_label)
    df = df_to_label[~df_to_label.index.isin(edit_indices)]
    for idx in edit_indices:
        text = df_to_label.loc[idx, 'text']
        row = {'text': text}
        labels = get_label(text, label_classes)
        row.update(dict(zip(label_classes, labels)))
        df = df.append(row, ignore_index=True)
    return df


def get_edit_indices(df_to_label):
    display(df_to_label)
    while True:
        res = input('edit indices: ')
        if not res:
            return []
        edit_indices = [int(idx) for idx in res.split(',')]
        if set(edit_indices).issubset(set(df_to_label.index.values)):
            return edit_indices


def display(df):
    dfc = df.copy()
    label_cols = get_label_cols(df)
    for label_col in label_cols:
        dfc[label_col] = dfc[label_col].apply(lambda x: label_col if x else '')
    join_cols = lambda cols: ','.join(cols).strip(',')
    dfc['labels'] = dfc[label_cols].apply(join_cols, axis=1)
    print()
    print(dfc[['text', 'labels']])
    print()
    return


def bulk_review(df, unlabeled_texts, label_classes, save_model, output_csv):
    label_cols = get_label_cols(df)
    while unlabeled_texts:
        model = train(df.text, df[label_cols], save_model)
        texts_to_label, unlabeled_texts = \
            sample_and_remove_n(unlabeled_texts, chunk_size)
        df_pred = pd.DataFrame(model.predict(texts_to_label),
                               columns=label_cols)
        df_pred.insert(loc=0, column='text', value=texts_to_label)
        df_labeled = get_labels_in_bulk(get_label, label_classes, df_pred)
        df = df.append(df_labeled, ignore_index=True)
        save(df, output_csv)
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('in_csv', help='one text per line')
    parser.add_argument('labels', nargs='+',
                        help='label categories for text')
    parser.add_argument('-xor', '--labels_are_mutually_exclusive',
                        action='store_true',
                        help='make labels are mutually exclusive')
    parser.add_argument('-rn', '--retrain_every_n', type=int, default=10,
                        help='retrain a model every n')
    parser.add_argument('-mer', '--max_error_rate_for_bulk_review',
                        type=float, default=0.10,
                        help='max error rate before bulk review')
    parser.add_argument('-ern', '--error_rate_last_n', type=int,
                        default=100, help='use last n to calculate error rate')
    parser.add_argument('-cs', '--chunk_size', type=int, default=50,
                        help='chunk size for bulk review')
    parser.add_argument('-sm', '--save_model',
                        help='name to save model as (not saved if no name)')
    parser.add_argument('-o', '--output_csv', default='output.csv',
                        help='output csv file')
    return parser.parse_args(argv[1:])


def signal_handler(signal, frame):
    sys.exit(0)
    return


if __name__ == '__main__':
    signal.signal(signal.SIGINT, signal_handler) 
    args = parse_args(sys.argv)
    label(args.in_csv,
          args.labels,
          args.labels_are_mutually_exclusive,
          args.retrain_every_n,
          args.max_error_rate_for_bulk_review,
          args.error_rate_last_n,
          args.chunk_size,
          args.save_model,
          args.output_csv)

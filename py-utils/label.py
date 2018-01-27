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
          min_labels_for_training,
          max_error_rate_for_bulk_review,
          error_rate_last_n,
          chunk_size,
          save_model,
          output_csv):

    get_df = get_multi_df
    get_label = get_multi_label
    if labels_are_mutually_exclusive:
        get_df = get_single_df
        get_label = get_single_label

    df = get_df(output_csv, label_classes)
    with open(in_csv) as f:
        unlabeled_texts = set(f.read().splitlines()) - set(df.text)
    

    n = min_labels_for_training - len(df)
    if n > 0:
        texts_to_label, unlabeled_texts = \
            sample_and_remove_n(unlabeled_texts, n)
        df = df.append(get_labels(get_label, texts_to_label, label_classes),
                       ignore_index=True)
        save(df, output_csv)

    label_cols = get_label_cols(df)
    model = train(df.text, df[label_cols], save_model)

    last_n_correct = [False] * error_rate_last_n
    error_rate = 1.0
    while error_rate > max_error_rate_for_bulk_review:
        text_to_label, unlabeled_texts = \
            sample_and_remove_n(unlabeled_texts, 1)
        pred_row = dict(zip(label_cols, model.predict([text_to_label])[0]))
        pred_row['text'] = text_to_label
        row = get_label(text_to_label, label_classes)
        df = df.append(row, ignore_index=True)
        model = train(df.text, df[label_cols], save_model)
        last_n_correct.insert(0, pred_row == row)
        last_n_correct.pop()
        error_rate = 1 - np.mean(last_n_correct)

    while unlabeled_texts:
        model = train(df.text, df[label_cols], save_model)
        df_to_label, unlabeled_texts = create_df_to_label(unlabeled_texts,
                                                          chunk_size,
                                                          model,
                                                          label_cols)
        df_labeled = get_labels_in_bulk(get_label, df_to_label, label_classes)
        df = df.append(df_labeled, ignore_index=True)
        save(df, output_csv)
    return


def create_df_to_label(unlabeled_texts, chunk_size, model, label_cols):
    texts_to_label, unlabeled_texts = \
        sample_and_remove_n(unlabeled_texts, chunk_size)
    df = pd.DataFrame(model.predict(texts_to_label), columns=label_cols)
    df.insert(loc=0, column='text', value=texts_to_label)
    return df, unlabeled_texts


def get_multi_df(output_csv, labels):
    colnames = list(labels) + ['text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv, na_filter=False).drop_duplicates()
        assert set(df.columns).issubset(set(colnames))
        assert (set(df.columns) - set(['text'])).issubset(labels)
    return df


def get_multi_label(text, label_classes):
    labels = {lblc: 0 for lblc in label_classes}
    labels['text'] = text
    while (True):
        lbl = input(text + ': ')
        if not lbl:
            return labels
        lbls = set([x.strip() for x in lbl.split(',')])
        if lbls.issubset(label_classes):
            for lbl in lbls:
                labels[lbl] = 1
            return labels


def get_single_df(output_csv, labels):
    colnames = ['label', 'text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv, na_filter=False).drop_duplicates()
        assert set(df.columns).issubset(set(colnames))
        assert set(df.label).issubset(labels)
    return df


def get_single_label(text, label_classes):
    label = input(text + ': ')
    while not label in label_classes:
        label = input(text + ': ')
    return {'label': label, 'text': text}


def sample_and_remove_n(superset, n):
    subset = random.sample(superset, min(n, len(superset)))
    if n == 1:
        subset = subset[0]
    return subset, superset - set(subset)


def save(df, output_csv):
    df.to_csv(output_csv, index=False, quoting=csv.QUOTE_NONNUMERIC)
    return


def get_labels(get_label, texts_to_label, label_classes):
    rows = []
    for text in texts_to_label:
        row = get_label(text, label_classes)
        rows.append(row)
    return pd.DataFrame(rows)


def get_label_cols(df):
    return list(set(df.columns) - set(['text']))


def train(X, y, save_model):
    p = make_pipeline(CountVectorizer(analyzer='char_wb',
                                      ngram_range=(2,4),
                                      stop_words='english',
                                      lowercase=True),
                      RandomForestClassifier(n_estimators=200))
    p.fit(X, y)
    if save_model:
        joblib.dump(p, save_model)
    return p


def get_labels_in_bulk(get_label, df_to_label, label_classes):
    edit_indices = get_edit_indices(df_to_label)
    df = df_to_label[~df_to_label.index.isin(edit_indices)]
    for idx in edit_indices:
        row = get_label(df_to_label.loc[idx, 'text'], label_classes)
        df = df.append(row, ignore_index=True)
    return df


def get_edit_indices(df_to_label):
    display(df_to_label)
    edit_indices = [int(idx) for idx in input('edit indices: ').split(',')]
    while not set(edit_indices).issubset(df_to_label.index):
        display(df_to_label)
        edit_indices = [int(idx) for idx in input('edit indices: ').split(',')]
    return edit_indices


def display(df):
    dfc = df.copy()
    label_cols = get_label_cols(df)
    for label_col in label_cols:
        dfc[label_col] = dfc[label_col].apply(lambda x: label_col if x else '')
    join_cols = lambda cols: ','.join(cols).strip(',')
    dfc['labels'] = dfc[label_cols].apply(join_cols, axis=1)
    print(dfc[['text', 'labels']])
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
    parser.add_argument('-min', '--min_labels_for_training',
                        type=int, default=50,
                        help='number of labels to have before training')
    parser.add_argument('-mer', '--max_error_rate_for_bulk_review',
                        type=float, default=0.01,
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
          set(args.labels),
          args.labels_are_mutually_exclusive,
          args.min_labels_for_training,
          args.max_error_rate_for_bulk_review,
          args.error_rate_last_n,
          args.chunk_size,
          args.save_model,
          args.output_csv)

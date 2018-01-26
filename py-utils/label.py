#!/usr/bin/env python3

import argparse
import csv
import os
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
    
    texts_to_label, unlabeled_texts = sample_and_remove_n(unlabeled_texts, 10)
    df.append(get_labels(get_label, texts_to_label, label_classes))
    save(df, output_csv)

    label_cols = get_label_cols(df)
    while unlabeled_texts:
        model = train(df.text, df[label_cols])
        if save_model:
            joblib.dump(model, save_model)
        texts_to_label, unlabeled_texts = sample_and_remove_n(unlabeled_texts,
                                                              chunk_size)
        df.append(get_labels_in_bulk(get_label,
                                     texts_to_label,
                                     label_classes,
                                     model))
        save(df, output_csv)
    return


def get_multi_df(output_csv, labels):
    colnames = list(labels) + ['text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv).drop_duplicates()
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
        lbls = set(lbl.split())
        if lbls.issubset(label_classes):
            for lbl in lbls:
                labels[lbl] = 1
            return labels


def get_single_df(output_csv, labels):
    colnames = ['label', 'text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv).drop_duplicates()
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
        rows.append(get_label(text, label_classes))
    return pd.DataFrame(rows)


def get_label_cols(df):
    return list(set(df.columns) - set(['text']))


def train(X, y):
    p = make_pipeline(CountVectorizer(analyzer='char_wb',
                                      ngram_range=(2,4),
                                      stop_words='english',
                                      lowercase=True),
                      RandomForestClassifier(n_estimators=200))
    p.fit(X, y)
    return p


def get_labels_in_bulk(get_label, texts_to_label, label_classes, model):
    tmp_df = pd.DataFrame(model.predict(texts_to_label),
                          columns=get_label_cols(df))
    tmp_df['text'] = texts_to_label
    print(tmp_df)
    edit_idxs = input('edit indices: ')
    while not set(edit_idxs).issubset(tmp_df.index):
        print(tmp_df)
        edit_idxs = input('edit indices: ')
    df = tmp_df[~tmp_df.index.isin(edit_idxs)]
    for edit_idx in edit_idxs:
        df.append(get_label(tmp_df.loc[edit_idx, 'text'], label_classes))
    return df
        

def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('in_csv', help='one text per line')
    parser.add_argument('labels', nargs='+',
                        help='label categories for text')
    parser.add_argument('-xor', '--labels_are_mutually_exclusive',
                        action='store_true',
                        help='make labels are mutually exclusive')
    parser.add_argument('-cs', '--chunk_size', type=int, default=40,
                        help='bulk label chunk size')
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
          args.chunk_size,
          args.save_model,
          args.output_csv)

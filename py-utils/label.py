#!/usr/bin/env python3

import argparse
import csv
import os
import pandas as pd
import random
import signal
import sys

from sklearn.feature_extraction.text import CountVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import make_pipeline


def label(in_csv, label_classes, exclusive, output_csv):
    get_df = get_multi_df
    add_labels_individually = add_multi_labels_individually
    add_labels_en_masse = add_multi_labels_en_masse
    if exclusive:
        get_df = get_single_df
        add_labels_individually = add_single_labels_individually
        add_labels_en_masse = add_single_labels_en_masse

    df = get_df(output_csv, label_classes)
    label_cols = set(df.columns) - set(['text'])
    with open(in_csv) as f:
        unlabeled_texts = set(f.read().splitlines()) - set(df.text)

    df, unlabeled_texts = \
        add_labels_individually(unlabeled_texts, label_classes, df, 100)
    while unlabeled_texts:
        model = train(df.text, df[label_cols])
        df, unlabeled_texts, error_rate = add_labels_en_masse(unlabeled_texts,
                                                              label_classes,
                                                              df,
                                                              model)
        df.to_csv(output_csv, index=False, quoting=csv.QUOTE_NONNUMERIC)
    return


def get_multi_df(output_csv, labels):
    colnames = list(labels) + ['text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv).drop_duplicates()
        assert set(df.columns).issubset(set(colnames))
        assert (set(df.columns) - set(['text'])).issubset(labels)
    return df


def get_single_df(output_csv, labels):
    colnames = ['label', 'text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv).drop_duplicates()
        assert set(df.columns).issubset(set(colnames))
        assert set(df.label).issubset(labels)
    return df



def add_multi_labels_individually(unlabeled_texts, label_classes, df, n):
    while len(df) < n:
        text, unlabeled_texts = sample_and_remove_n(unlabeled_texts, 1)
        row = get_multi_label(text, label_classes)
        df.append(row)
    return df, unlabeled_texts


def sample_and_remove_n(superset, n):
    subset = random.sample(superset, min(n, len(superset)))
    if n == 1:
        subset = subset[0]
    return subset, superset - set(subset)


def get_multi_label(text, label_classes):
    labels = {lblc: 0 for lblc in label_classes}
    labels['text'] = text
    while (True):
        lbl = input(text + ': ')
        if not lbl:
            return labels
        lbls = set(lbl.split(','))
        if lbls.issubset(label_classes):
            for lbl in lbls:
                labels[lbl] = 1
            return labels


def add_multi_labels_en_masse(unlabeled_texts, label_classes, df, model):
    texts_to_label, unlabeled_texts = sample_and_remove_n(unlabeled_texts)
    labels = model.predict(texts_to_label)
    # TODO(danj)


def add_single_labels_individually(unlabeled_texts, label_classes, df, n):
    while len(df) < n:
        text, unlabeled_texts = sample_and_remove_n(unlabeled_texts, 1)
        row = get_single_label(text, label_classes)
        df.append(row)
    return df, unlabeled_texts


def get_single_label(text, label_classes):
    # TODO(danj)



def add_single_labels_en_masse(unlabeled_texts, label_classes, df, model):
    # TODO(danj)
    texts_to_label, unlabeled_texts = \
        get_sample(unlabeled_texts, sample_n(error_rate))
    text_labels = [list(labels)[0]] * len(texts_to_label)
    if model:
        text_labels = model.predict(texts_to_label)
    label_width = len(max(list(labels), key=len)) + 2
    fmt = '{idx:<4}{label:<%d}{text}' % label_width
    msg = ''
    for idx, (label, text) in enumerate(zip(text_labels, texts_to_label)):
        msg += fmt.format(idx=idx, label=label, text=text) + '\n'
    edits = get_edits(msg, labels)
    for idx, label in edits:
        text_labels[int(idx)] = label
    df_samples = pd.DataFrame({'label': text_labels, 'text': texts_to_label})
    error_rate = len(edits) / len(texts_to_label)
    return df.append(df_samples), unlabeled_texts, error_rate


def get_edits(msg, labels):
    while True:
        print(msg)
        res = input('edits [h]: ')
        if res == 'h':
            print('format: <idx>:<label><space><idx>:<label>...\n')
            continue
        elif any_malformatted_edits(res, labels):
            continue
        else:
            return [e.split(':') for e in res.split()]


def any_malformatted_edits(res, labels):
    edits = res.split()
    for idx_lbl in edits:
        if not ':' in idx_lbl:
            return True
    for idx_lbl in edits:
        _, lbl = idx_lbl.split(':')
        if lbl not in labels:
            return True
    return False


def train(X, y):
    p = make_pipeline(CountVectorizer(analyzer='char_wb',
                                      ngram_range=(2,4),
                                      stop_words='english',
                                      lowercase=True),
                      RandomForestClassifier(n_estimators=200))
    p.fit(X, y)
    return p
        

def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('in_csv', help='one text per line')
    parser.add_argument('labels', nargs='+',
                        help='label categories for text')
    parser.add_argument('-xor', '--labels_mutually_exclusive',
                        action='store_true',
                        help='make labels mutually exclusive')
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
          args.labels_mutually_exclusive,
          args.output_csv)

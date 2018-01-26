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


def label_single(in_csv, labels, output_csv):
    df = get_label_single_df(output_csv, labels)
    with open(in_csv) as f:
        unlabeled_texts = set(f.read().splitlines()) - set(df.text)

    model = None
    error_rate = 1.0
    df, unlabeled_texts, error_rate = \
        add_single_labels(unlabeled_texts, labels, df, model, error_rate)

    while unlabeled_texts:
        df, unlabeled_texts, error_rate = \
            add_single_labels(unlabeled_texts, labels, df, model, error_rate)
        if len(df) >= 10 and error_rate > 0.01:
            model = train(df.text, df.label)
        df.to_csv(output_csv, index=False, quoting=csv.QUOTE_NONNUMERIC)
    return


def get_label_single_df(output_csv, labels):
    colnames = ['label', 'text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv).drop_duplicates()
        assert set(df.columns).issubset(set(colnames))
        assert set(df.label).issubset(labels)
    return df


def add_single_labels(unlabeled_texts, labels, df, model, error_rate):
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


def sample_n(error_rate, min_n = 10, max_n = 40):
    if error_rate == 0:
        return max_n
    return min(max(int(1 / error_rate), min_n), max_n)


def get_sample(superset, n):
    subset = random.sample(superset, min(n, len(superset)))
    return subset, superset - set(subset)


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


def label_multi(in_csv, labels, output_csv):
    df = get_label_multi_df(output_csv, labels)
    texts = set(df.texts)
    with open(in_csv) as f:
        texts = set(f.read().splitlines())
    return


def get_label_multi_df(output_csv, labels):
    colnames = list(labels) + ['text']
    df = pd.DataFrame(columns=colnames)
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv).drop_duplicates()
        assert set(df.columns).issubset(set(colnames))
    return df
        

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
    if args.labels_mutually_exclusive:
        label_single(args.in_csv, set(args.labels), args.output_csv)
    else:
        label_multi(args.in_csv, set(args.labels), args.output_csv)

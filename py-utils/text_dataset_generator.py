#!/usr/bin/env python3

import argparse
import csv
import os
import pandas as pd
import sys


def make_training_dataset(csv_file,
                          label_categories,
                          default_label,
                          sample_n,
                          output_csv):

    label_categories = set(label_categories)
    if default_label:
        assert default_label in label_categories, 'default label invalid!'

    labels = []
    texts = []
    texts_set = set()
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv, na_filter=False)
        labels = list(df['label'])
        texts = list(df['text'])
        texts_set = set(texts)
        assert set(labels).issubset(label_categories), 'label mismatch!'
        
    count = 0
    with open(csv_file) as f:
        for text in f:
            text = text.strip()
            if text in texts_set:
                continue
            lbls = get_labels(text, label_categories, default_label)
            labels.extend(lbls)
            texts.extend([text] * len(lbls))
            texts_set.add(text)
            count += 1
            if count >= sample_n:
                break

    df = pd.DataFrame({'label': labels, 'text': texts})
    df.to_csv(output_csv, index=False, quoting=csv.QUOTE_NONNUMERIC)
    print('output saved to %s!' % output_csv)
    return


def get_labels(text, label_categories, default_label):
    msg = make_msg(text, default_label)
    while (True):
        lbl = input(msg)
        if not lbl:
            lbl = default_label
        if ',' in lbl:
            lbls = lbl.split(',')
            for lbl in lbls:
                if lbl not in label_categories:
                    continue
        else:
            if lbl not in label_categories:
                continue
            lbls = [lbl]
        return lbls


def make_msg(text, default_label):
    msg = text + ' : '
    if default_label:
        msg = text + ' (%s): ' % default_label
    return msg


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('source_csv', help='format (per line): "text"')
    parser.add_argument('label_categories', nargs='+')
    parser.add_argument('-d', '--default_label')
    parser.add_argument('-n', '--sample_n', default=10, type=int,
                        help='how many values to sample')
    parser.add_argument('-o', '--output_csv', default='train.csv',
                        help='output file')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    make_training_dataset(args.source_csv,
                          args.label_categories,
                          args.default_label,
                          args.sample_n,
                          args.output_csv)

#!/usr/bin/env python3

import argparse
import csv
import os
import pandas as pd
import sys


def make_training_dataset(csv_file,
                          label_classes,
                          sample_n,
                          output_csv):

    label_classes = set(label_classes)

    df = pd.DataFrame(columns=sorted(label_classes) + ['text'])
    texts = set()
    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv, na_filter=False)
        texts = set(df['text'].unique())
        assert (set(df.columns) - set(['text'])).issubset(label_classes)
        
    count = 0
    with open(csv_file) as f:
        for text in f:
            text = text.strip()
            if text in texts:
                continue
            row = get_labels(text, label_classes)
            df = df.append(row, ignore_index=True)
            texts.add(text)
            count += 1
            if count >= sample_n:
                break

    df.to_csv(output_csv, index=False, quoting=csv.QUOTE_NONNUMERIC)
    print('output saved to %s!' % output_csv)
    return


def get_labels(text, label_classes):
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


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('source_csv', help='format (per line): "text"')
    parser.add_argument('label_classes', nargs='+')
    parser.add_argument('-n', '--sample_n', default=10, type=int,
                        help='how many values to sample')
    parser.add_argument('-o', '--output_csv', default='train.csv',
                        help='output file')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    make_training_dataset(args.source_csv,
                          args.label_classes,
                          args.sample_n,
                          args.output_csv)

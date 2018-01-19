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
    labeled_texts = set()
    texts = set()

    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv, na_filter=False)
        all_labels = df['label']
        all_texts = df['text']
        labeled_texts = set(zip(all_labels, all_texts))
        texts = set(all_texts)
        assert set(all_labels).issubset(label_categories), 'label mismatch!'
        
    count = 0
    with open(csv_file) as f:
        for text in f:
            text = text.strip()
            if text in texts:
                continue
            msg = text + ' : '
            if default_label:
                msg = text + ' (%s): ' % default_label
            label = input(msg)
            if not label and default_label:
                label = default_label
            while (label not in label_categories):
                label = input(msg)
            labeled_texts.add((label, text))
            texts.add(text)
            count += 1
            if count >= sample_n:
                break

    labels = []
    texts = []
    for label, text in labeled_texts:
        labels.append(label)
        texts.append(text)

    df = pd.DataFrame({'label': labels, 'text': texts})
    print(df)
    df.to_csv(output_csv, index=False, quoting=csv.QUOTE_NONNUMERIC)
    print('output saved to %s!' % output_csv)
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('source_csv', help='format (per line): "text"')
    parser.add_argument('label_categories', nargs='+')
    parser.add_argument('-d', '--default_label')
    parser.add_argument('-n', '--sample_n', default=10,
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

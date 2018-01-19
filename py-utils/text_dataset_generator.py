#!/usr/bin/env python3

import argparse
import os
import pandas as pd
import sys


def make_training_dataset(csv_file, label_categories, sample_n, output_csv):
    label_categories = set(label_categories)
    labeled_texts = set()
    texts = set()

    if os.path.exists(output_csv):
        df = pd.read_csv(output_csv)
        all_labels = df['label']
        all_texts = df['text']
        labeled_texts = set(zip(all_labels, all_texts))
        texts = set(all_texts)
        assert set(all_labels).issubset(label_categories), 'label mismatch!'
        
    count = 0
    with open(csv_file) as f:
        for text in f:
            if text in current_texts:
                continue
            print(text)
            label = input('Label: ')
            while (label not in label_categories):
                label = input('Label: ')
            labeled_texts.add((label, text))
            texts.add(text)
            count += 1
            if count >= sample_n:
                break

    # TODO(danj): sort out writing
    df = pd.DataFrame({'label': labels, 'text': texts})
    df.to_csv(output_csv, index=False)
    print('output saved to %s!' % output_csv)
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('source_csv', help='format (per line): "text"')
    parser.add_argument('label_categories', nargs='+')
    parser.add_argument('-n', '--sample_n', default=10,
                        help='how many values to sample')
    parser.add_argument('-o', '--output_csv', default='train.csv',
                        help='output file')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    make_training_dataset(args.source_csv,
                          args.label_categories,
                          args.sample_n,
                          args.output_csv)

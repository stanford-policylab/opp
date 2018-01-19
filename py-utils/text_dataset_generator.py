#!/usr/bin/env python3

import argparse
import pandas as pd
import sys


def make_training_dataset(csv_file, output_csv):
    labels = []
    with open(csv_file) as f:
        for line in f:
            print(line)
            res = input('Label: ')
            while (res not in args.labels):
                res = input('Label: ')
            labels.append(res)
            texts.append(line)
    df = pd.DataFrame({'label': labels, 'text': texts})
    df.to_csv(output_csv, index=False)
    print('output saved to %s!' % output_csv)
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('csv_file', help='format (per line): "text"')
    parser.add_argument('labels', nargs='+')
    parser.add_argument('-o', '--output_csv', default='train.csv')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    make_training_dataset(args)

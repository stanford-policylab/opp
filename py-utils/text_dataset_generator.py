#!/usr/bin/env python3

import argparse
import pandas as pd
import sys


def make_training_dataset(args):
    df = pd.read_csv(args.csv_file, usecols=[args.column])
    pass


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('csv_file')
    parser.add_argument('column')
    parser.add_argument('labels', nargs='+')
    parser.add_argument('-o', '--output_file', default='train.txt')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    make_training_dataset(args)

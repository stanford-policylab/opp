#!/usr/bin/env python3

import argparse
import csv
import pandas as pd
import sys

from sklearn.externals import joblib
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import make_pipeline


def train_on(train_csv, model_name):
    df = pd.read_csv(train_csv, na_filter=False)
    label_cols = [col for col in df if col != 'text']
    train(df.text, df[label_cols], model_name, label_cols)
    return


def train(X, y, save_model=None, label_names=None):
    # NOTE: stemming and punctuation?
    p = make_pipeline(CountVectorizer(analyzer='char_wb',
                                      ngram_range=(2,4),
                                      stop_words='english',
                                      lowercase=True),
                      RandomForestClassifier(n_estimators=200))
    p.label_names = label_names
    if y.shape[1] == 1:
        y = y.iloc[:, 0].ravel()
    p.fit(X, y)
    if save_model:
        joblib.dump(p, save_model)
    return p


def predict_on(model_file, test_csv, pred_csv):
    m = joblib.load(model_file)
    df = pd.read_csv(test_csv, names=['text'], na_filter=False)
    dfp = pd.DataFrame(m.predict(df['text']), columns=m.label_names)
    dfp.join(df).to_csv(pred_csv, index=False, quoting=csv.QUOTE_NONNUMERIC)
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    sub = parser.add_subparsers(help='commands', dest='command')
    train = sub.add_parser(
        'train',
        help='train a model',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    train.add_argument(
        '-f',
        '--train_csv',
        default='train.csv',
        help='format (per line): label,"text"'
    )
    train.add_argument(
        '-m' ,
        '--model_name',
        default='a.model',
        help='model name'
    )
    pred = sub.add_parser(
        'predict',
        help='predict on unlabeled data',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    pred.add_argument(
        '-m',
        '--model_name',
        default='a.model',
        help='model file'
    )
    pred.add_argument(
        '-f',
        '--test_csv',
        default='test.csv',
        help='format (per line): "text"'
    )
    pred.add_argument(
        '-o',
        '--pred_csv',
        default='pred.csv',
        help='output csv'
    )
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    if args.command == 'train':
        train_on(args.train_csv, args.model_name)
    else:
        predict_on(args.model_name, args.test_csv, args.pred_csv)

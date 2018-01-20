#!/usr/bin/env python3

import argparse
import csv
import pandas as pd
import sys

from nltk.corpus import stopwords
from sklearn.externals import joblib
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import make_pipeline


def train(train_csv, model_name):
    df = pd.read_csv(train_csv, na_filter=False)
    # NOTE: stemming and punctuation?
    p = make_pipeline(CountVectorizer(analyzer='char',
                                      ngram_range=(2,4),
                                      stop_words=stopwords.words(),
                                      lowercase=True),
                      MultinomialNB())
    p.fit(df['text'], df['label'])
    joblib.dump(p, model_name)
    print('model saved as %s' % model_name)
    return


def predict(model_file, test_csv, output_csv):
    m = joblib.load(model_file)
    df = pd.read_csv(test_csv, names=['text'], na_filter=False)
    df['pred'] = m.predict(df['text'])
    df.to_csv(output_csv, columns=['pred', 'text'], index=False,
              quoting=csv.QUOTE_NONNUMERIC)
    print('output written to %s' % output_csv)
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    sub = parser.add_subparsers(help='commands', dest='command')
    train = sub.add_parser('train', help='train a model',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    train.add_argument('-f', '--train_csv', default='train.csv',
                       help='format (per line): label,"text"')
    train.add_argument('-mn' , '--model_name', default='model',
                       help='model name')
    pred = sub.add_parser('predict', help='predict on unlabeled data',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    pred.add_argument('-f', '--test_csv', default='test.csv',
                      help='format (per line): "text"')
    pred.add_argument('-mn', '--model_name', default='model',
                      help='model file')
    pred.add_argument('-o', '--output_csv', default='output.csv',
                      help='output csv')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    if args.command == 'train':
        train(args.train_csv, args.model_name)
    else:
        predict(args.model_name, args.test_csv, args.output_csv)

#!/usr/bin/env python3

import argparse
import sys

from nltk.corpus import stopwords
from sklearn.externals import joblib
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import make_pipeline


def train(train_file, model_name):
    y = []
    X = []
    with open(train_file) as f:
        for line in f:
            label, text = line.split(' ', 1)
            y.append(label)
            X.append(text)
    # NOTE: stemming and punctuation?
    p = make_pipeline(CountVectorizer(analyzer='char',
                                      ngram_range=(2,4),
                                      stop_words=stopwords,
                                      lowercase=True),
                      MultinomialNB())
    p.fit(X, y)
    joblib.dump(p, model_name)
    print('model saved as %s' % model_name)
    return


def predict(model_file, test_file, output_file):
    m = joblib.load(model_file)
    X = []
    with open(test_file) as f:
        for text in f:
            X.append(text)
    preds = m.predict(X)
    assert len(preds) == len(X), 'Predictions and texts do not align!'
    with open(output_file, 'w') as f:
        f.write('label text\n')
        for pred, text in zip(preds, X):
            f.write(pred + ' ' + text + '\n')
    print('output written to %s' % output_file)
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    sub = parser.add_subparsers(help='commands', dest='command')
    train = sub.add_parser('train', help='train a model')
    train.add_argument('train_file', help='label text, 1 per line (space sep)',
                       default='train.txt')
    train.add_argument('model_name', help='model name', default='model')
    pred = sub.add_parser('predict', help='predict on unlabeled data')
    pred.add_argument('model_file', help='model file', default='model')
    pred.add_argument('test_file', help='test file, 1 text per line')
    pred.add_argument('output_file', help='output file', default='output.csv')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    if args.command == 'train':
        train(args.train_file, args.model_name)
    else:
        predict(args.model_file, args.test_file, args.output_file)

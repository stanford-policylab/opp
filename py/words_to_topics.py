#!/usr/bin/env python3
import argparse
import json
import os
import sys

from collections import Counter, defaultdict
from itertools import chain

from nltk import word_tokenize


def words_to_topics(topic_dict):
    word_max_count = defaultdict(int)
    word_topic_dict = {}
    for topic, tokens in topic_dict.items():
        words = set(tokens)  # maintain original casing
        counts = Counter([token.lower() for token in tokens])
        for word in words:
            w = word.lower()
            c = counts.get(w)
            if c > word_max_count[w]:
                word_max_count[w] = c
                word_topic_dict[word] = topic
    topic_words_dict = defaultdict(list) 
    for word, topic in word_topic_dict.items():
        topic_words_dict[topic].append(word)
    return dict(topic_words_dict)


def read_and_tokenize(filename):
    with open(filename) as f:
        lines = [word_tokenize(line) for line in f.read().splitlines()]
    return list(chain(*lines))


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('topic_files', nargs='+', help='one file per topic')
    parser.add_argument('-o', '--output_json', default='output.json',
                        help='output json file')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    topic_dict = {}
    for topic_file in args.topic_files:
        topic = os.path.basename(topic_file).split('.')[0]
        topic_dict[topic] = read_and_tokenize(topic_file)
    topic_words_dict = words_to_topics(topic_dict)
    with open(args.output_json, 'w') as f:
        json.dump(topic_words_dict, f, indent=2, sort_keys=True)

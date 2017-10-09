#!/usr/bin/env python3

from pprint import pprint

import argparse
import sys

import googlemaps
import pandas as pd

from datetime import datetime


def get_client(key):
    return googlemaps.Client(key=key)


def get_key(args):
    key = args.api_key
    if not key:
        with open(args.api_key_file) as f:
            key = f.read().strip()
    return key


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0])
    parser.add_argument('csv_file')
    parser.add_argument('location_column_name')
    parser.add_argument('-api_key')
    parser.add_argument('-api_key_file', default='google_maps_api.key')
    return parser.parse_args(argv[1:])

if __name__ == '__main__':
    args = parse_args(sys.argv)
    c = get_client(get_key(args))
    df = pd.read_csv(args.csv_file)
    lats = []
    longs = []
    for loc in df[args.location_column_name]:
        d = c.geocode(loc)
        pprint(d)
        loc = d[0]['geometry']['location']
        lats.append(loc['lat'])
        longs.append(loc['lng'])
    df['lat'] = lats
    df['long'] = longs
    print(df[[args.location_column_name, 'lat', 'long']])

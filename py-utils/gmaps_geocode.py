#!/usr/bin/env python3

import argparse
import sys

import googlemaps
import pandas as pd

from datetime import datetime


class GM(object):
    
    def __init__(self, api_key):
        self.c = googlemaps.Client(key=api_key)

    def geocode(self, loc):
        d = self.c.geocode(loc)
        return self._extract_lat_lng(d)

    def _extract_lat_lng(self, data):
        coords = d[0]['geometry']['location']
        return coords['lat'], coords['lng']


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
    gm = GM(get_key(args))
    df = pd.read_csv(args.csv_file)
    lats = []
    lngs = []
    for loc in df[args.location_column_name]:
        d = gm.geocode(loc)
        loc = d[0]['geometry']['location']
        lats.append(loc['lat'])
        lngs.append(loc['lng'])
    df['lat'] = lats
    df['lng'] = lngs
    print(df[[args.location_column_name, 'lat', 'lng']])

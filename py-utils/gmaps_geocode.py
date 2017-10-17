#!/usr/bin/env python3

import argparse
import csv
import logging
import os
import sys

import googlemaps
import pandas as pd

from collections import namedtuple
from datetime import datetime


LOG_FILE = 'geocode.log'
logging.basicConfig(filename=LOG_FILE, level=logging.INFO)


GeocodedLocation = namedtuple('GeocodedLocation', ['loc', 'lat', 'lng'])


class GM(object):
    
    def __init__(self, api_key):
        self.c = googlemaps.Client(key=api_key)

    def geocode(self, loc):
        d = self.c.geocode(loc)
        return self._extract_lat_lng(d)

    def _extract_lat_lng(self, data):
        coords = data[0]['geometry']['location']
        return coords['lat'], coords['lng']


def get_key(args):
    key = args.api_key
    if not key:
        with open(args.api_key_file) as f:
            key = f.read().strip()
    return key


def extract_unique_locations(csv_files, location_column_name):
    locs = set()
    for csv_file in args.csv_files:
        df = pd.read_csv(csv_file)
        locs.update(df[args.location_column_name].unique())
    return locs


def path_of_this_file():
    return os.path.dirname(os.path.realpath(__file__))


def path_relative_to_this_file(file_path):
    return os.path.join(path_of_this_file(), file_path)


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0])
    parser.add_argument('csv_files', nargs='+')
    parser.add_argument('location_column_name')
    parser.add_argument('-output_file_csv', default='geocoded_locations.csv')
    parser.add_argument('-api_key')
    parser.add_argument('-api_key_file',
                        default=path_relative_to_this_file('gmaps_api.key'))
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    gm = GM(get_key(args))
    locs = extract_unique_locations(args.csv_files, args.location_column_name)
    glocs = []
    for loc in locs:
        try:
            logging.info(loc)
            lat, lng = gm.geocode(loc)
            glocs.append(GeocodedLocation(loc, lat, lng))
        except Exception as e:
            logging.error(loc)
    with open(args.output_file_csv, 'w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerow(['loc', 'lat', 'lng'])
        for gloc in glocs:
            csv_writer.writerow([gloc.loc, gloc.lat, gloc.lng])
    print('Output: ' + args.output_file_csv + '\nLog:' + LOG_FILE)

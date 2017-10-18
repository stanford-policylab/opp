#!/usr/bin/env python3

import argparse
import csv
import os
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
        coords = data[0]['geometry']['location']
        return coords['lat'], coords['lng']


def get_key(args):
    key = args.api_key
    if not key:
        with open(args.api_key_file) as f:
            key = f.read().strip()
    return key


def extract_locations(csv_files,
                      location_column_name,
                      output_file_csv,
                      errors_file):
    locs = set()
    for csv_file in args.csv_files:
        df = pd.read_csv(csv_file)
        locs.update(df[args.location_column_name].unique())
    existing_locs = set()
    if os.path.exists(output_file_csv):
        existing_locs.update(pd.read_csv(output_file_csv)['loc'].unique())
    errors = set()
    if os.path.exists(errors_file):
        with open(errors_file) as f:
            for line in f:
                errors.update(line.strip())
    return locs - existint_locs - errors


def path_of_this_file():
    return os.path.dirname(os.path.realpath(__file__))


def path_relative_to_this_file(file_path):
    return os.path.join(path_of_this_file(), file_path)


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0])
    parser.add_argument('csv_files', nargs='+')
    parser.add_argument('location_column_name')
    parser.add_argument('-o', '--output_file_csv',
                        default='geocoded_locations.csv',
                        help='if the file already exists, the addresses'
                             ' already present in the file will be skipped,'
                             ' and new addresses appended')
    parser.add_argument('-e', '--errors_file',
                        default='geocoded_locations_errors.csv',
                        help='errors are output to this file; if the file'
                             ' already exists, addresses in this file will be'
                             ' skipped and new errors appended')
    parser.add_argument('-api_key')
    parser.add_argument('-api_key_file',
                        default=path_relative_to_this_file('gmaps_api.key'))
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    gm = GM(get_key(args))
    locs = extract_locations(args.csv_files,
                             args.location_column_name,
                             args.output_file_csv,
                             args.error_file)
    print('Getting addresses for %d locations...' % len(locs))
    print('Writing output to ' + args.output_file_csv)
    print('Writing errors to ' + args.errors_file)
    with open(args.output_file_csv, 'a', newline='') as output, \
        open(args.errors_file, 'a') as errors:
        output = csv.writer(output)
        errors = csv.writer(errors)
        output.writerow(['loc', 'lat', 'lng'])
        for loc in locs:
            try:
                lat, lng = gm.geocode(loc)
                output.writerow([loc, lat, lng])
            except Exception as e:
                errors.writerow([loc])

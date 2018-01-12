#!/usr/bin/env python3

import argparse
import csv
import math
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
                      location_column_names,
                      location_column_sep,
                      output_file_csv,
                      errors_file_csv):
    locs = set()
    for csv_file in csv_files:
        df = pd.read_csv(csv_file)
        df = add_loc_col(df, location_column_names, location_column_sep)
        locs.update(df['loc'].unique())
    existing_locs = set()
    if os.path.exists(output_file_csv):
        existing_locs.update(pd.read_csv(output_file_csv)['loc'].unique())
    errors = set()
    if os.path.exists(errors_file_csv):
        with open(errors_file_csv) as f:
            for line in f:
                errors.update(line.strip())
    return locs - existing_locs - errors


def add_loc_col(df, location_column_names, location_column_sep):
    df['loc'] = col_as_str(df, location_column_names[0])
    for loc_col in location_column_names[1:]:
        df['loc'] += location_column_sep + col_as_str(df, loc_col)
    df['loc'] = df['loc'].str.strip()
    return df


def col_as_str(df, col):
    return df[col].fillna('').astype('str').str.strip()


def path_of_this_file():
    return os.path.dirname(os.path.realpath(__file__))


def path_relative_to_this_file(file_path):
    return os.path.join(path_of_this_file(), file_path)


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog=argv[0], formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-f', '--csv_files', nargs='+')
    parser.add_argument('-l', '--location_column_names', nargs='+',
                        help='if multiple, list in order to compose'
                             ' an address')
    parser.add_argument('-s', '--location_column_sep', nargs=1, type=str,
                        help='separator for location columns; default space',
                        default=' ')
    parser.add_argument('-o', '--output_file_csv',
                        default='geocoded_locations.csv',
                        help='if the file already exists, the addresses'
                             ' already present in the file will be skipped,'
                             ' and new addresses appended;'
                             ' default: ./geocoded_locations.csv')
    parser.add_argument('-e', '--errors_file_csv',
                        default='geocoded_locations_errors.csv',
                        help='errors are output to this file; if the file'
                             ' already exists, addresses in this file will be'
                             ' skipped and new errors appended;'
                             ' default: ./geocoded_locations_errors.csv')
    parser.add_argument('-api_key')
    parser.add_argument('-api_key_file',
                        default=path_relative_to_this_file('gmaps_api.key'))
    parser.add_argument('-as', '--address_suffix',
                        help='append to the end of the address,'
                             ' i.e. ", Seattle, WA"',
                        default='')
    parser.add_argument('-n', help='sample the first n for testing',
                        default=math.inf, type=float)
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    gm = GM(get_key(args))
    locs = extract_locations(args.csv_files,
                             args.location_column_names,
                             args.location_column_sep,
                             args.output_file_csv,
                             args.errors_file_csv)
    print('Getting addresses for %d locations...' % len(locs))
    print('Writing output to ' + args.output_file_csv)
    print('Writing errors to ' + args.errors_file_csv)
    output_file_csv_already_exists = os.path.exists(args.output_file_csv)
    count = 0
    with open(args.output_file_csv, 'a', newline='') as ocsv, \
        open(args.errors_file_csv, 'a') as ecsv:
        output = csv.writer(ocsv)
        errors = csv.writer(ecsv)
        if not output_file_csv_already_exists:
            output.writerow(['loc', 'lat', 'lng'])
        for loc in locs:
            try:
                lat, lng = gm.geocode(loc + args.address_suffix)
                output.writerow([loc, lat, lng])
                ocsv.flush()
            except Exception as e:
                errors.writerow([loc])
                ecsv.flush()
            count += 1
            if count > args.n:
                break

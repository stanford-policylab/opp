#!/usr/bin/env python3

import argparse
import sys

import overpass
import pandas as pd

from datetime import datetime


class OSM(object):

    def __init__(self):
        self.c = overpass.API()

    def geocode(self, loc):
        query = self._generate_query(loc)
        d = self.c.Get(query)
        return self._extract_lat_long(d)

    def _generate_query(self, loc):
        pass

    def _extract_lat_long(self, data):
        pass


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0])
    parser.add_argument('csv_file')
    parser.add_argument('location_column_name')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    osm = OSM()
    df = pd.read_csv(args.csv_file)
    lats = []
    lngs = []
    for loc in df[args.location_column_name]:
        lat, lng = osm.geocode(loc)
        lats.append(lat)
        lngs.append(lng)

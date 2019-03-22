#!/usr/bin/env python3
import glob
import os
import pandas as pd


for path in glob.iglob('../data/**/geocoded_locations.csv', recursive=True):
    base, fn = os.path.split(path)
    output_path = os.path.join(base, "geocoded_locations_sanitized.csv")
    d = pd.read_csv(path)
    median_lat = d.lat.median()
    median_lng = d.lng.median()
    lat_std = d.lat.std()
    lng_std = d.lng.std()
    n_std = 4
    tmp = d[
        (d.lat > median_lat - n_std * lat_std)
        & (d.lat < median_lat + n_std * lat_std)
        & (d.lng > median_lng - n_std * lng_std)
        & (d.lng < median_lng + n_std * lng_std)
    ]
    removed = d.shape[0] - tmp.shape[0]
    removed_pct = 0.0
    if (d.shape[0]):
        removed_pct = removed / d.shape[0] * 100
    print('removed %d (%f pct) of rows from %s' % (removed, removed_pct, path))
    tmp.to_csv(output_path, index=False)

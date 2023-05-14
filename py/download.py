#!/usr/bin/env python3
from collections import defaultdict
from multiprocessing import Pool, cpu_count
from pathlib import Path
from urllib.request import urlopen, urlretrieve
import argparse
import re
import sys

IFRAME_URL = "https://embed.stanford.edu/iframe?url="
BASE_PURL = "https://purl.stanford.edu/yg821jf8611"
URL = IFRAME_URL + BASE_PURL


def download(re_state, re_city, file_type, output_dir, list_only):
    dir_path = Path(output_dir)
    dir_path.mkdir(parents=True, exist_ok=True)
    p_state = re.compile(re_state, re.IGNORECASE)
    p_city = re.compile(re_city, re.IGNORECASE)
    d = get_urls()
    tasks = []
    for state, city_d in d.items():
        s = state.upper()
        if not p_state.match(s):
            continue
        for city, urls in city_d.items():
            c = city.replace('_', ' ').title()
            if not p_city.match(c):
                continue
            url = urls.get(file_type)
            if not url:
                continue
            fname = file_name(url)
            path = dir_path.joinpath(fname)
            tasks.append((s, c, file_type, url, path))
    tasks = sorted(tasks)
    if not tasks:
        sys.exit('No matched locations')
    if list_only:
        for (state, city, _, _, _) in tasks:
            print(f'{city}, {state}')
        sys.exit(0)
    with Pool(cpu_count()) as pool:
        pool.starmap(_download, tasks)


def _download(state, city, file_type, url, path):
    sub = f'{file_type} for {city}, {state}'
    if path.exists():
        print(f'{sub} already exists at {path}', flush=True)
        return
    print(f'Downloading {sub} to {path}...', flush=True)
    urlretrieve(url, path)


def get_urls():
    data = urlopen(URL).read().decode('utf8')
    urls = list(set(re.findall(r'href=[\'"]?([^\'" >]+)', data)) - {BASE_PURL})
    urls = filter(lambda url: 'data_readme.md' not in url, urls)
    d = nested_default_dict(3, str)
    for url in urls:
        state, city, file_type = info(url)
        d[state][city][file_type] = url
    return to_regular_dict(d)


def nested_default_dict(depth, base_type):
    def recurse(depth, base_type):
        if depth == 0:
            return base_type
        return lambda: defaultdict(recurse(depth - 1, base_type))

    return recurse(depth, base_type)()


def to_regular_dict(dd):
    if isinstance(dd, defaultdict):
        dd = {k: to_regular_dict(v) for k, v in dd.items()}
    return dd


def info(url):
    terms = resolve_location(url)
    # Temporary fix for resolve_location ValueError
    if len(terms) != 2:
        return "NA", "NA", resolve_file_type(url)
    state, city = terms
    file_type = resolve_file_type(url)
    return state, city, file_type


def resolve_location(url):
    loc = re.split('_shapefiles|_2020', file_name(url))[0]
    return loc.split('_', 1)


def file_name(url):
    return url.split('/')[-1].split('_', 1)[-1]  # remove SDR hash prefix


def resolve_file_type(url):
    if url.endswith('.csv.zip'):
        return 'csv'
    if url.endswith('.rds'):
        return 'rds'
    if '_shapefiles_' in url:
        return 'shapefiles'
    return 'unknown'


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog=argv[0],
        description='download OPP data',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '-l',
        '--list',
        help='list options only',
        action='store_true',
        default=False,
    )
    parser.add_argument(
        '-s',
        '--state',
        default='.*',
        help='two letter state code (can be regex)',
    )
    parser.add_argument(
        '-c',
        '--city',
        default='.*',
        help='city (can be regex)',
    )
    parser.add_argument(
        '-t',
        '--file_type',
        default='csv',
        choices=['csv', 'rds', 'shapefiles'],
        help='file type to download',
    )
    parser.add_argument(
        '-o',
        '--output_directory',
        default='/tmp/opp_data',
        help='where to download all data',
    )
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    download(
        args.state,
        args.city,
        args.file_type,
        args.output_directory,
        args.list,
    )

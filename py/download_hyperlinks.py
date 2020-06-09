#!/usr/bin/env python3

import argparse
import os
import re
import sys
import urllib.request

from bs4 import BeautifulSoup, SoupStrainer
from pprint import pprint

import utils


def download(base_url, hyperlink_regex, output_dir):
    if not base_url.endswith('/'):
        base_url += '/'
    hrx = re.compile(hyperlink_regex)
    with urllib.request.urlopen(base_url) as response:
        html = response.read()
    link_fname_tuples = []
    for link in BeautifulSoup(html,
                              "html.parser",
                              parse_only=SoupStrainer('a')):
        if link.has_attr('href') and hrx.match(link['href']):
            link_fname_tuples.append((base_url + link['href'], link['href']))
    print()
    pprint([fname for _, fname in link_fname_tuples])
    if utils.confirm('\nDownload these files?'):
        utils.make_dir(output_dir)
        for link, fname in link_fname_tuples:
            output_path = os.path.join(output_dir, fname)
            print('saving %s to %s...' % (fname, output_path), end='')
            urllib.request.urlretrieve(link, os.path.join(output_dir, fname))
            print('done')
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog=argv[0], formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('base_url',
                        help='url to search for hyperlinks to download')
    parser.add_argument(
        'hyperlink_regex',
        help='regex to match against hyperlinks and download on base_url')
    parser.add_argument('-o',
                        '--output_dir',
                        help='save all downloaded links to this directory')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    download(args.base_url, args.hyperlink_regex, args.output_dir)

#!/usr/bin/env python3

import argparse
import pandas as pd
import os
import re
import subprocess as sub
import sys

from lookup import lookup
from utils import (
    opp_root_dir,
    git_pull_rebase_if_online,
)


def make():
    # r_data_readme = os.path.join(opp_root_dir(), 'lib', 'data_readme.R')
    # sub.run(['Rscript', r_data_readme])
    tables = pd.read_csv('/tmp/data_readme.csv')
    results = lookup('all', 'all', 'all', n_lines_after=0, update_repo=False)
    for r in results:
        idx = (tables.city == r['city']) & (tables.state == r['state'])
        # NOTE: this happens when there is code but the data is bad
        if not any(idx):
            print('Skipping %s, %s' % (r['city'], r['state']))
            continue
        r['table'] = tables.loc[idx, 'predicated_null_rates'].tolist()[0]
    write_md(results)
    return results


def write_md(results):
    with open('data_readme.md', 'w') as f:
        for r in results:
            if not 'table' in r:
                continue
            f.write('## %s, %s\n' % (r['city'], r['state']))
            f.write(r['table'] + '\n')
            d = {'validation': [], 'note': [], 'todo': []}
            for m in r['matches']:
                p = remove_leading_hashes(m['match']).replace('\n', ' ')
                ctype, text = p.split(':', 1)
                # NOTE: remove person assigned task if exists
                ctype = re.sub('\(\w+\)', '', ctype)
                # NOTE: remove [RED|YELLOW|GREEN] rating if exists
                text = re.sub('\[\w+\]', '', text)
                # NOTE: remove asana task links
                text = re.sub(r'https://app.asana\S+', '', text)
                d[ctype.lower()].append({
                    'comment': text.strip(),
                    'code': m['after'] if 'after' in m else '',
                })
            write_list(f, 'Validation', d['validation'])
            write_list(f, 'Notes', d['note'])
            write_list(f, 'Issues', d['todo'])
            f.write('\n\n')
    return


def remove_leading_hashes(s):
    return re.sub(re.compile('^\s*#\s*', re.MULTILINE), '', s)


def write_list(f, name, lst):
    f.write('\n### %s:\n' % name)
    for d in lst:
        cmt = d['comment'].replace('can we get', 'missing')
        f.write('- %s\n' % d['comment'])
        if d['code']:
            f.write('```r\n%s```\n' % d['code'])
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    make()

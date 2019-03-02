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


def make(rerun_r, add_comments, output_dir):
    if rerun_r:
        r_data_readme = os.path.join(opp_root_dir(), 'lib', 'data_readme.R')
        sub.run(['Rscript', r_data_readme])
    tables = pd.read_csv('/tmp/data_readme.csv')
    results = lookup('all', 'all', 'all', n_lines_after=0, update_repo=False)
    for r in results:
        idx = (tables.city == r['city']) & (tables.state == r['state'])
        # NOTE: this happens when there is code but the data is bad
        if not any(idx):
            print('Skipping %s, %s' % (r['city'], r['state']))
            continue
        r['table'] = tables.loc[idx, 'predicated_null_rates'].tolist()[0]
        r['date_range'] = tables.loc[idx, 'date_range'].tolist()[0]
    write_md(results, add_comments, output_dir)
    return results


def write_md(results, add_comments, output_dir):
    with open('data_readme_template.md') as f:
        contents = f.readlines()
    for r in results:
        if not 'table' in r:
            continue
        title = '## %s, %s\n' % (r['city'], r['state'])
        left, right = contents.split(title)
        insert = [title]
        insert.append("### %s\n" % r['date_range'])
        insert.append(r['table'] + '\n')
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
        if add_comments:
            insert.extend(to_list('Validation', d['validation']))
            insert.extend(to_list('Notes', d['note']))
            insert.extend(to_list('Issues', d['todo']))
        insert.append('\n\n')
        contents = ''.join(left + insert + right)
    with open(os.path.join(output_dir, 'data_readme.md'), 'w') as f:
        f.write(contents)
    return


def remove_leading_hashes(s):
    return re.sub(re.compile('^\s*#\s*', re.MULTILINE), '', s)


def to_list(name, lst):
    v = '\n### %s:\n' % name
    for d in lst:
        cmt = d['comment']
        if 'can we get' in cmt:
            cmt = cmt.replace('can we get', 'missing').replace('?', '')
        v.append('- %s\n' % cmt)
        if d['code']:
            v.append('```r\n%s```\n' % d['code'])
    return v


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('-a', '--add_comments')
    parser.add_argument('-r', '--rerun_r', action = 'store_true')
    parser.add_argument('-o', '--output_dir', default='..')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    make(args.rerun_r, args.add_comments, args.output_dir)

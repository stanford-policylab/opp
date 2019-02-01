#!/usr/bin/env python3

import argparse
import glob
import os
import re
import sys

from lookup import lookup
from utils import (
    opp_root_dir,
    git_pull_rebase_if_online,
)


def make():
    paths = get_data_paths()
    results = lookup('all', 'all', 'all', n_lines_after=0, update_repo=False)
    return paths, results


def get_data_paths():
    pattern = os.path.join(opp_root_dir(), 'data', 'states', '**', '*.rds')
    return [p for p in glob.iglob(pattern, recursive=True)]


def write_md(results):
    with open('results.md', 'w') as f:
        for r in results:
            f.write('## %s, %s\n' % (r['city'], r['state']))
            d = {'validation': [], 'note': [], 'todo': []}
            for match in r['matches']:
                comment, code = split_comment_code(match)
                comment_type, text = comment.split(':', 1)
                # NOTE: remove person assigned task if exists
                comment_type = re.sub('\(\w+\)', '', comment_type)
                d[comment_type.lower()].append({
                    'comment': text.strip(),
                    'code': code,
                })
            write_list(f, 'Validation', d['validation'])
            write_list(f, 'Notes', d['note'])
            write_list(f, 'Todos', d['todo'])
            f.write('\n\n')
    return


def write_list(f, name, lst):
    f.write('\n### %s:\n' % name)
    for d in lst:
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

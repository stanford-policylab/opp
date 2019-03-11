#!/usr/bin/env python3
import argparse
import os
import re
import sys


def organize(input_r_file):
    with open(input_r_file) as f:
        contents = f.read()
    funcs = re.split(r'\n+(?=\w+ <- function)', contents)
    # NOTE: first block has libraries/sources
    imports = '\n'.join([v for v in sorted(funcs[0].split('\n')) if v])
    d = []
    for func in funcs[1:]:
        name, _ = func.split('<-', 1)
        d.append((name.strip(), func.strip()))
    vs = [imports] + [body for name, body in sorted(d)]
    fn, _ = os.path.basename(input_r_file).split('.')
    out_fn = fn + '_organized.R'
    with open(out_fn, 'w') as f:
        f.write('\n\n\n'.join(vs))
    print('output %s' % out_fn)
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('input_r_file')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    organize(args.input_r_file)

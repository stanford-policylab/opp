#!/usr/bin/env python3


'''
create a new directory structure and template for given city
'''


import argparse
import os
import sys

from shutil import copyfile

from utils import chdir_to_opp_root, make_dir


def init(args):
    chdir_to_opp_root()
    state = args.state.lower()
    city = '_'.join([x.lower() for x in args.city])
    make_data_dirs(state, city)
    make_lib_dirs(state)
    copy_template(args.template, state, city)
    return


def make_data_dirs(state, city):
    parent_dir = os.path.join('data', 'states', state, city)
    sub_dirs = ['raw', 'raw_csv', 'clean', 'geocodes']
    for sub_dir in sub_dirs:
        make_dir(os.path.join(parent_dir, sub_dir))
    return


def make_lib_dirs(state):
    make_dir(os.path.join('lib', 'states', state))
    return


def copy_template(template_path, state, city):
    dst = os.path.join('lib', 'states', state, city + '.R')
    if not os.path.exists(dst):
        copyfile(template_path, dst)
    return


def parse_args(argv):
    desc = 'initializes the data and lib directories for a new city'
    default_template = 'lib/states/wa/seattle.R'
    parser = argparse.ArgumentParser(prog=argv[0], description=desc)
    parser.add_argument('state')
    parser.add_argument('city', nargs='+')
    parser.add_argument('-template', default=default_template,
                        help='default: ' + default_template)
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    init(parse_args(sys.argv))

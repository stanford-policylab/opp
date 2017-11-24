#!/usr/bin/env python3


'''
create a new directory structure and template for given city
'''


import argparse
import os
import sys

from shutil import copyfile


def init(args):
    chdir_to_opp_city_root()
    state = args.state.lower()
    city = '_'.join([x.lower() for x in args.city])
    make_data_dirs(state, city)
    make_lib_dirs(state)
    copy_template(args.template, state, city)
    return


def chdir_to_opp_city_root():
    path = os.path.dirname(os.path.realpath(__file__))
    # NOTE: this assumes opp-city root is parent directory of this file
    parent = os.path.abspath(os.path.join(path, os.pardir))
    os.chdir(parent)
    return


def make_data_dirs(state, city):
    parent_dir = os.path.join('data', 'states', state, city)
    sub_dirs = ['raw', 'raw_csv', 'clean', 'geocodes']
    for sub_dir in sub_dirs:
        make_dir(os.path.join(parent_dir, sub_dir))
    return


def make_dir(d):
    if not os.path.exists(d):
        os.makedirs(d)
    return


def make_lib_dirs(state):
    make_dir(os.path.join('lib', 'states', state))
    return


def copy_template(template_path, state, city):
    copyfile(template_path, os.path.join('lib', 'states', city + '.R'))


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0])
    parser.add_argument('state')
    parser.add_argument('city', nargs='+')
    parser.add_argument('-template', default='lib/states/wa/seattle.R')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    init(parse_args(sys.argv))

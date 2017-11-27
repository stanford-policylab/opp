#!/usr/bin/env python3

import os
import sys
import argparse
import subprocess as sub
import tempfile


from utils import (
    chdir_to_opp_root, 
    make_dir,
    strip_margin, 
)


def generate_report(state, city):
    opp_root_dir = chdir_to_opp_root()
    make_reports_dir(opp_root_dir)
    rcmd = strip_margin('''
    library(rmarkdown)
    library(knitr)
    render(
      'lib/report.Rmd',
      'pdf_document',
      '../reports/{state_}_{city_}_report.pdf',
      params = list(
        state = '{state_}',
        city = '{city_}',
        set_title = '{city}, {state}'
      )
    )
    '''.format(state = state,
               state_ = state.lower(),
               city = ' '.join(city),
               city_ = '_'.join(city).lower())
    )
    with tempfile.NamedTemporaryFile('w+', delete=False) as f:
        f.write(rcmd)
        f.flush()
        try:
            sub.check_call('Rscript %s' % f.name, shell=True)
        except Exception as e:
            print(e)
            print('Failed to make report! Are the R packages'
                  ' rmarkdown and knitr installed?')
            sys.exit(1)
    print('Report saved to reports directory!')
    return


def make_reports_dir(opp_root_dir):
    reports_dir = os.path.join(opp_root_dir, 'reports')
    make_dir(reports_dir)
    return


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0])
    parser.add_argument('state')
    parser.add_argument('city', nargs='+')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    generate_report(args.state, args.city)

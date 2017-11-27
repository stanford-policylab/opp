#!/usr/bin/env python3

import re
import sys
import argparse
import subprocess as sub
import tempfile


def generate_report(state, city):
    rcmd = strip_margin('''
    library(rmarkdown)
    library(knitr)
    render(
      'lib/report.Rmd',
      'pdf_document',
      '{state_}_{city_}_report.pdf',
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
    return


def strip_margin(text):
    indent = len(min(re.findall('\n[ \t]*(?=\S)', text) or ['']))
    pattern = r'\n[ \t]{%d}' % (indent - 1)
    return re.sub(pattern, '\n', text)


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0])
    parser.add_argument('state')
    parser.add_argument('city', nargs='+')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    generate_report(args.state, args.city)

#!/usr/bin/env python3

import sys
import argparse
import subprocess as sub


def generate_report(state, city):
    rcmd = "library(rmarkdown); library(knitr);"
    rcmd += " render('lib/Report.Rmd', 'pdf_document', '../out/{state}_{city_}.pdf',"
    rcmd += " params = list("
    rcmd += " state = '{state}',"
    rcmd += " city = '{city}',"
    rcmd += " set_title = '{city}, {state}'"
    rcmd += " ))"
    rcmd = rcmd.format(state=state, city=city, city_=city.replace(' ', '_'))
    cmd = ['Rscript', '-e', '"' + rcmd + '"']
    _run(cmd, shell=True)
    return


def _run(cmd, **kwargs):
    if 'shell' in kwargs:
        # if arguments need to be interpreted or spawn subshells
        # the cmd must be a single string and shell=True
        cmd = ' '.join(cmd)
    p = sub.Popen(cmd, stdout=sub.PIPE, stderr=sub.PIPE, **kwargs)
    so, se = p.communicate()
    ret = p.returncode
    cmd_str = 'COMMAND: ' + str(cmd)
    if ret:  # non-zero return code
        _print_red(cmd_str + '\n\tFAILED!')
        _print_yellow('STDOUT:\n' + str(so))
        _print_red('STDERR:\n' + str(se))
    else:
        _print_green(cmd_str + '\n\tSUCCEEDED!')
    return so


def _print_red(s):
    print('\033[91m' + s + '\033[0m')


def _print_green(s):
    print('\033[92m' + s + '\033[0m')


def _print_yellow(s):
    print('\033[93m' + s + '\033[0m')


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0])
    parser.add_argument('state')
    parser.add_argument('city', nargs='+')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv)
    generate_report(args.state, ' '.join(args.city))

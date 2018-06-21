#!/usr/bin/env python3

import argparse
import os
import re
import sys

from utils import (
    chdir_to_opp_root,
    git_pull_rebase_if_online,
    syntax_higlight_code,
)

def lookup(
        regex,
        state,
        city,
        n_lines_before,
        n_lines_after,
        update_repo,
    ):

    if update_repo:
        git_pull_rebase_if_online('.')

    chdir_to_opp_root()

    states_dir = os.path.join('lib', 'states')

    states = [state]
    if state == 'all':
        states = os.listdir(states_dir)

    for state in states:
        cities = [normalize(city) + '.R']
        if city == 'all':
            cities = os.listdir(os.path.join(states_dir, state))
        for city_filename in cities:
            city_path = os.path.join(states_dir, state, city_filename)
            # NOTE: catches degenerate case when 'all' specified for state
            # and a specific city name provided, i.e. 'long beach'
            if not os.path.exists(city_path):
                continue
            matches = find(regex, city_path, n_lines_before, n_lines_after)
            matches_formatted = syntax_highlight(matches)
            state_name = state.upper()
            city_name = make_proper_noun(
                city_filename.split('.')[0].replace('_', ' ')
            )
            display(state_name, city_name, matches_formatted)
    return


def normalize(name):
    return name.lower().replace(' ', '_')


def find(regex, path, n_lines_before, n_lines_after):
    regexc = re.compile(regex)
    with open(path) as f:
        code = f.read()
    if regexc.match('notes?'):
        return find_all_notes(code, n_lines_before, n_lines_after)
    # TODO(danj): add possible assignee here
    elif regexc.match('todos?'):
        return find_all_todos(code, n_lines_before, n_lines_after)
    elif regexc.match('files?'):
        return [code]
    else:
        # NOTE: if the user provided a single token, match containing line
        if re.compile('^\w+$').match(regex):
            regex = '(.*' + regex + '.*\n)'
        return find_all(regex, code, n_lines_before, n_lines_after)


def find_all_notes(code, n_lines_before, n_lines_after):
    regex = '(.*#\s+NOTE.*\n)(.*#.*\n)*'
    return find_all(regex, code, n_lines_before, n_lines_after)


def find_all_todos(code, n_lines_before, n_lines_after):
    regex = '(.*#\s+TODO.*\n)(.*#.*\n)*'
    return find_all(regex, code, n_lines_before, n_lines_after)


def find_all(regex, code, n_lines_before, n_lines_after):
    line_regex = '(.*\n)'
    regexc = re.compile(
        '{before}{match}{after}'.format(
            # NOTE: repeated matches of capture groups aren't allowed by re
            # StackOverflow: http://www.goo.gl/aKqPFG
            before=line_regex * n_lines_before,
            match=regex,
            after=line_regex * n_lines_after
        )
    )
    matches = []
    for captures in regexc.findall(code):
        match = ''.join([capture for capture in captures if capture != ''])
        matches.append(match)
    return matches


def syntax_highlight(matches):
    return [syntax_higlight_code(match, 'R') for match in matches]


def display(state, city, matches):
    header = '\n------------- %s, %s ' % (city, state)
    colmax = 80
    header += '-' * (colmax - len(header))
    print(header)
    for match in matches:
        print(match + '-------------')
    return


def make_proper_noun(name):
    return name.title()


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        'regex',
        help=(
            'special tokens: "file" will return entire file contents '
            '"note" will return all NOTEs, and "todo" will return all '
            'TODOs'   
        )
    )
    parser.add_argument(
        'state',
        help='two letter state code; type "all" to get all states'
    )
    parser.add_argument(
        'city',
        help='city or "statewide"; type "all" to get all cities within a state'
    )
    parser.add_argument(
        '-b',
        '--n_lines_before',
        type=int,
        default=0,
        help='returns n lines of context before regex pattern match',
    )
    parser.add_argument(
        '-a',
        '--n_lines_after',
        type=int,
        default=3,
        help='returns n lines of context after regex pattern match',
    )
    parser.add_argument(
        '-u',
        '--update_repo',
        action='store_true',
        help='update repo before searching'
    )
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    args = parse_args(sys.argv) 
    lookup(
        args.regex,
        args.state,
        args.city,
        args.n_lines_before,
        args.n_lines_after,
        args.update_repo,
    )

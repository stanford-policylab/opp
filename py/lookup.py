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
    pattern,
    state,
    city,
    n_lines_after,
    md,
    update_repo,
):

    if update_repo:
        git_pull_rebase_if_online('.')

    chdir_to_opp_root()

    states_dir = os.path.join('lib', 'states')

    states = [state]
    if state == 'all':
        states = os.listdir(states_dir)

    results = []
    for state in states:
        state = state.lower()
        cities = [normalize(city) + '.R']
        if city == 'all':
            cities = os.listdir(os.path.join(states_dir, state))
        for city_filename in cities:
            city_path = os.path.join(states_dir, state, city_filename)
            # NOTE: catches degenerate case when 'all' specified for state
            # and a specific city name provided, i.e. 'long beach'
            if not os.path.exists(city_path):
                continue
            matches = find(pattern, city_path, n_lines_after)
            state_name = state.upper()
            city_name = make_proper_noun(
                city_filename.split('.')[0].replace('_', ' ')
            )
            d = {'state': state_name, 'city': city_name, 'matches': matches}
            results.append(d)
    if md:
        write_md(results)
    else:
        [display(**d) for d in results]
    return


def normalize(name):
    return name.lower().replace(' ', '_')


def find(pattern, path, n_lines_after):
    pattern_rx = re.compile(pattern, re.IGNORECASE)
    with open(path) as f:
        code = f.read()
    if pattern_rx.match('all?'):
        return (
            find_all(special_regex()['validation'], code, n_lines_after)
            + find_all(special_regex()['note'], code, n_lines_after)
            + find_all(special_regex()['todo'], code, n_lines_after)
        )
    if pattern_rx.match('notes?'):
        return find_all(special_regex()['note'], code, n_lines_after)
    # TODO(danj): add possible assignee here
    elif pattern_rx.match('todos?'):
        return find_all(special_regex()['todo'], code, n_lines_after)
    elif pattern_rx.match('validation'):
        return find_all(special_regex()['validation'], code, n_lines_after)
    elif pattern_rx.match('files?'):
        return [code]
    else:
        # NOTE: if the user provided a single token, match containing line
        if re.compile('^\w+$').match(pattern):
            pattern = '.*' + pattern + '.*'
        return find_all(pattern, code, n_lines_after)


def special_regex():
    return {
        'note': '^\s*#\s*NOTE:.*',
        'todo': '^\s*#\s*TODO:.*',
        'validation': '^\s*#\s*VALIDATION:.*',
    }


def find_all(pattern, code, n_lines_after):
    pattern_rx = re.compile(pattern)
    comment_rx = re.compile('.*#.*')
    special_rx = re.compile('|'.join(special_regex().values()))
    matches = []
    last_was_comment = False
    lines = code.split('\n')
    n = len(lines)
    for i, line in enumerate(lines):
        if pattern_rx.match(line):
            matches.append(line)
            if comment_rx.match(line):
                last_was_comment = True
        elif (
            last_was_comment
            and comment_rx.match(line)
            and not special_rx.match(line)
        ):
            matches[-1] += '\n' + line
        elif last_was_comment:
            last_was_comment = False
            matches[-1] += '\n' + '\n'.join(lines[i:min(i + n_lines_after, n)])
    return matches


def syntax_highlight(matches):
    return [syntax_higlight_code(match, 'R') for match in matches]


def display(state, city, matches):
    header = '\n------------- %s, %s ' % (city, state)
    colmax = 80
    header += '-' * (colmax - len(header))
    print(header)
    for match in syntax_highlight(matches):
        print(match + '-------------')
    return


def make_proper_noun(name):
    return name.title()


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
            write_list(f, 'TODOs', d['todo'])
            f.write('\n\n')
    return


def write_list(f, name, lst):
    f.write('\n### %s:\n' % name)
    for d in lst:
        f.write('- %s\n' % d['comment'])
        if d['code']:
            f.write('```r%s```\n' % d['code'])
    return


def split_comment_code(s):
    comments = []
    codes = []
    for line in s.split('\n'):
        if re.match('^\s*#', line):
            comments.append(re.sub('^\s*#\s*', '', line))
        else:
            codes.append(line)
    return ' '.join(comments), '\n'.join(codes)


def parse_args(argv):
    parser = argparse.ArgumentParser(
        prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        'pattern',
        help=(
            'special tokens: "file" will return entire file contents '
            '"note" will return all NOTEs, and "todo" will return all '
            'TODOs, "valid(ation)" will return all VALIDATIONs, and "all" '
            'will return VALIDATIONs, NOTEs, and TODOs'
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
        '-a',
        '--n_lines_after',
        type=int,
        default=0,
        help='returns n lines of context after regex pattern match',
    )
    parser.add_argument(
        '-md',
        action='store_true',
        help='output as md file'
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
        args.pattern,
        args.state,
        args.city,
        args.n_lines_after,
        args.md,
        args.update_repo,
    )

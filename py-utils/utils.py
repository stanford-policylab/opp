import os
import re
import sys


def chdir_to_opp_root():
    this_dir = os.path.dirname(os.path.realpath(__file__))
    # NOTE: this assumes opp-city root is parent directory of this file
    opp_root_dir = os.path.abspath(os.path.join(this_dir, os.pardir))
    os.chdir(opp_root_dir)
    return opp_root_dir


def make_dir(d):
    if not os.path.exists(d):
        os.makedirs(d)
    return


def strip_margin(text):
    indent = len(min(re.findall('\n[ \t]*(?=\S)', text) or ['']))
    pattern = r'\n[ \t]{%d}' % (indent - 1)
    return re.sub(pattern, '\n', text)


def confirm(question, default='yes'):
    valid = {
        'yes': True,
        'y': True,
        'ye': True,
        'no': False,
        'n': False
    }
    prompt = ' [{yes}/{no}] '.format(
        yes='Y' if default == 'yes' else 'y',
        no='N' if default == 'no' else 'n'
    )
    while True:
        print(question + prompt, end='')
        choice = input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            print('please respond with "[y]es" or "[n]o"')

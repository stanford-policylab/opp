import os
import re
import sys


def chdir_to_opp_root():
    d = opp_root_dir()
    os.chdir(d)
    return d


def opp_root_dir():
    this_dir = os.path.dirname(os.path.realpath(__file__))
    # NOTE: this assumes opp root is parent directory of this file
    return os.path.abspath(os.path.join(this_dir, os.pardir))


def is_online():
    import socket
    try:
        socket.create_connection(("www.google.com", 80))
        return True
    except OSError:
        pass
    return False


def syntax_highlight_code(code, language):
    from pygments import highlight
    from pygments.lexers import get_lexer_by_name
    from pygments.formatters import Terminal256Formatter
    return highlight(
        code,
        get_lexer_by_name(language),
        Terminal256Formatter()
    )


def syntax_highlight_path(path):
    from pygments import highlight
    from pygments.lexers import get_lexer_for_filename
    from pygments.formatters import Terminal256Formatter
    with open(path) as f:
        code = f.read()
    return highlight(
        code,
        get_lexer_for_filename(filename),
        Terminal256Formatter()
    )


def make_dir(d):
    if not os.path.exists(d):
        os.makedirs(d)
    return


def git_pull_rebase(git_dir):
    import git
    git.cmd.Git(git_dir).pull('--rebase')
    return


def git_pull_rebase_if_online(git_dir):
    if (is_online()):
        git_pull_rebase(git_dir)
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

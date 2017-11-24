#!/usr/bin/env python3


'''
converts files from <ext> to csv files

To support <ext> conversions:
1. Add a function named <ext>_to_csv to the CONVERTERS section below
2. You can use the require(<program_name>) to ensure that an executable exists
3. You can use run(<command>) to run a bash command
4. Files should be saved in the current directory with the same filename and a
csv extension, so /path/to/file.xls saves to file.csv
5. You can use to_csv_ext(<filename>) to get <filename> with a csv extension
'''


import argparse
import os
import re
import sys

import pandas as pd
import subprocess as sub
import xml.etree.ElementTree as et


############################### CONVERTERS ####################################

def xls_to_csv(in_file):
    require('ssconvert', "try installing 'gnumeric' package on linux")
    out_file = to_csv_ext(in_file)
    run(['ssconvert', '--export-file-per-sheet', in_file, out_file])
    for filename in os.listdir('.'):
        if '.csv.' in filename:
            basename, index = filename.split('.csv.')
            new_out_filename = '%s_sheet_%d.csv' % (basename, int(index) + 1)
            os.rename(filename, new_out_filename)
    return


def xlsx_to_csv(in_file):
    return xls_to_csv(in_file)


def mdb_to_csv(in_file):
    require('mdb-tables', "try installing 'mdbtools' package on linux")
    require('mdb-export', "try installing 'mdbtools' package on linux")
    out_file = to_csv_ext(in_file)
    stdout = run(['mdb-tables', '-1', in_file])
    tbls = [tbl for tbl in stdout.split('\n') if tbl != '']
    for tbl in tbls:
        contents = run(['mdb-export', in_file, tbl])
        with open(out_file, 'w') as f:
            f.write(contents)
    return


def accdb_to_csv(in_file):
    mdb_to_csv(in_file)
    return


def xml_to_csv(in_file):
    '''
    https://stackoverflow.com/questions/41776263/ \
    pandas-read-xml-method-test-strategies
    '''
    tree = et.parse(in_file)
    data = []
    inner = {}
    for el in tree.iterfind('./*'):
        for i in el.iterfind('*'):
            inner[i.tag] = i.text
        data.append(inner)
        inner = {}
    df = pd.DataFrame(data)
    df.to_csv(to_csv_ext(in_file))
    return


###############################################################################

def convert(files_or_dirs):
    for f_or_d in files_or_dirs:
        if not os.path.exists(f_or_d):
            perr(f_or_d + " doesn't exist!")
        elif os.path.isfile(f_or_d):
            convert_file(f_or_d)
        elif os.path.isdir(f_or_d):
            for f in os.listdir(f_or_d):
                convert_file(os.path.join(f_or_d, f))
        else:
            perr(f_or_d + " isn't a file or directory!")
    return


def convert_file(filename):
    perr('converting %s...' % filename, end='')
    if is_supported(get_file_type(filename)):
        get_converter(filename)(filename)
        perr('done')
        return
    perr(" it's not a supported file type!")
    return


def get_file_type(filename):
    return os.path.splitext(filename)[1].lstrip('.')


def is_supported(file_type):
    return file_type in supported_file_types()


def supported_file_types():
    return [re.sub('_to_csv', '', func) for func in get_to_csv_funcs()]


def get_to_csv_funcs():
    return [k for k in globals().keys() if k.endswith('_to_csv')]


def perr(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)
    sys.stderr.flush()
    return


def get_converter(filename):
    file_type = get_file_type(filename)
    func_name = file_type + '_to_csv'
    return globals()[func_name]


def require(program, debug=''):
    if not which(program):
        perr(program + ' is a binary required for conversion, and is missing!')
        if debug:
           perr(debug) 
        sys.exit(1)
    return


# source: https://tinyurl.com/yd5f6l6d
def which(program):
    '''
    emulates linux which command to find an executable's full path
    '''
    fpath, _ = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file
    return


def is_exe(fpath):
    return os.path.isfile(fpath) and os.access(fpath, os.X_OK)


def run(cmd, **kwargs):
    if 'shell' in kwargs:
        # if arguments need to be interpreted or spawn subshells
        # the cmd must be a single string and shell=True
        cmd = ' '.join(cmd)
    p = sub.Popen(cmd, stdout=sub.PIPE, stderr=sub.PIPE, **kwargs)
    so, se = p.communicate()
    ret = p.returncode
    cmd_str = 'COMMAND: ' + str(cmd)
    if ret:  # non-zero return code
        perr(cmd_str + '\n\tFAILED!')
        perr(cmd_str)
        perr('STDOUT:\n' + str(so))
        perr('STDERR:\n' + str(se))
    return so.decode('utf-8')


def to_csv_ext(filename):
    base = filename_without_ext(filename)
    base_norm = normalize_filename(base)
    return base_norm + '.csv'


def filename_without_ext(filename):
    return os.path.splitext(os.path.basename(filename))[0]


def normalize_filename(filename):
    return filename.lower().replace(' ', '_')


def parse_args(argv):
    desc = 'supported file types: ' + ', '.join(supported_file_types())
    parser = argparse.ArgumentParser(prog=argv[0], description=desc)
    parser.add_argument('files_or_dirs', nargs='+',
                        help='a.xlsx b.xls c.mdb d.xml data/')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    ARGS = parse_args(sys.argv)
    convert(ARGS.files_or_dirs)

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

import subprocess as sub


############################### CONVERTERS ####################################

def xls_to_csv(in_file):
    require('ssconvert', "try installing 'gnumeric' package on linux")
    out_file = to_csv_ext(in_file)
    run(['ssconvert', '--export-file-per-sheet', in_file, out_file])
    for filename in os.listdir('.'):
        if '.csv.' in filename:
            basename, index = filename.split('.csv.')
            new_out_filename = '%s_sheet_%s.csv' % (basename, index)
            os.rename(filename, new_out_filename)
    return


def xlsx_to_csv(in_file):
    xls_to_csv(in_file)


###############################################################################

def convert(filenames, dirs):
    if filenames:
        convert_files(filenames)
    if dirs:
        for d in dirs:
            if not os.path.exists(d):
                perr(d + " doesn't exist!")
                continue
            convert_files(list(os.listdir(d)))
    return


def convert_files(filenames):
    for filename in filenames:
        perr('converting %s...' % filename)
        if not os.path.exists(filename):
            perr(filename + " doesn't exist!")
            continue
        if not is_supported(get_file_type(filename)):
            perr(filename + "isn't a supported file type!")
            continue
        get_converter(filename)(filename)
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
    return so


def to_csv_ext(filename):
    base = filename_without_ext(filename)
    return base + '.csv'


def filename_without_ext(filename):
    return os.path.splitext(os.path.basename(filename))[0]


def parse_args(argv):
    desc = 'supported file types: ' + ', '.join(supported_file_types())
    parser = argparse.ArgumentParser(prog=argv[0], description=desc)
    parser.add_argument('-f', '--files', nargs='+', help='a.xlsx b.xls c.mdb')
    parser.add_argument('-d', '--dirs', nargs='+', help='directories of files')
    return parser.parse_args(argv[1:])


if __name__ == '__main__':
    ARGS = parse_args(sys.argv)
    convert(ARGS.files, ARGS.dirs)

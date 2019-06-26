# Georgia's csv files are unquoted. This script tries to remove
# as many errors as possible.

import os
import csv
import codecs

state = "GA"
path_raw = '../data/states/ga/statewide/raw/'
path_csv = '../data/states/ga/statewide/calculated_features/'


# Try to fix row when it breaks.
def try_fix_row(row, file, i):
    # sometimes location has up to three values
    if row[42] != '' or row[43] != '':
        row = row[:41] + [row[41] + ' ' + row[42] + ' ' + row[43]] + row[43:]
        return row
    # officer names single column
    if ' ' in row[53] or '.' in row[53] or (row[53] in ['TEASLEY','TURNER',
            'MORGAN','CKNIGHT','LEWIS','LIPHAM','ORANGE','TENNANT','PROSSER',
            'GAMMON','BELL','FULLER',] and row[54].isdigit()):
        row = row[:53] + [row[2][1:], row[2][0]] + row[54:]
        return row
    # extra comma cases
    if row[68] != '' and row[79] == '':
        row = row[:67] + [row[67] + ' ' + row[68]] + row[69:]
        return row
    if row[85] not in ['','True','False']:
        row = row[:83] + [row[83] + ' ' + row[84]] + row[85:]
        return row
    if row[47] == '':
        row = row[:47] + row[48:]
        return row
    else:
        # hard-fix, return broken
        row[0] += 'XXX'
        row[42] = ''
        if len(row) < 103:
            row = row + ['']*(103-len(row))
        return row[:103]


# do all files in sequence
for file in os.listdir(path_raw):
    if '.txt' not in file:
        continue
    if '201' not in file:
        continue
    # make filenames
    fn_in  = path_raw + file
    fn_out = path_csv + file[:-4].replace(' ', '_' ) + '.csv'
    print "\nDoing", fn_in
    # open writer connection
    f_out = open(fn_out, 'wb')
    writer = csv.writer(f_out, delimiter=',', quoting=csv.QUOTE_MINIMAL)
    # open reader connection
    f_in = open(fn_in, 'rb')
    reader = csv.reader(f_in, delimiter=',', quoting=csv.QUOTE_MINIMAL)
    # read lines into memory
    lines = [row for row in reader]
    print '%d rows read' % len(lines)
    # iterate rows
    (i,n,f,b) = (0,0,0,0)
    while i < len(lines):
        row = lines[i]
        # fix lines w broken newlines
        while len(row) < 100:
            i += 1
            if len(lines[i]) > 1:
                row = row[:len(row)-1] + [row[len(row)-1][:-1] + ' ' + lines[i][0]] + lines[i][1:]
        while len(row) != 103 or row[42] != '':
            row = try_fix_row(row, file, i)
            f += 1
        writer.writerow(row)
        if 'XXX' in row[0]:
            b += 1  # update bad count
        else:
            n += 1  # update good count
        i += 1  # update index
    # close file connections
    f_in.close()
    f_out.close()
    # print result stats
    print '%d rows written\n%d fixed\n%d still bad\n' % (n,f,b)

#!/usr/bin/env python3
"""Transform NJ CAD CSVs to a standard CSV format.

The NJ cad20xx.csv raw files are in a strange format, repeating the column
headers on each line.

Transform these to a standard CSV format.
"""

import argparse
import csv
import os
import shutil
import sys
import tempfile
from typing import List



def get_raw_file_list(source_dir: str, prefix: str = "cad") -> List[str]:
    """Get a list of CSVs to process.
   
    Arguments:
        :source_dir: Directory containing raw files
        :prefix: CAD file prefix

    Returns:
        List of CSVs.
    """
    return [os.path.join(source_dir, fn) for fn in os.listdir(source_dir) if
            os.path.isfile(os.path.join(source_dir, fn)) and
            fn.startswith(prefix)]


def process_file(fn: str, out_dir: str, cols: int = 15) -> None:
    """Fix the input file and write fixed version the given out directory.

    Arguments:
        :fn: Source CSV
        :out_dir: Output directory (assumed to exist)
        :cols: Number of real columns to parse
    """
    fh_tmp_in = tempfile.SpooledTemporaryFile(mode='w+')
    fh_out = tempfile.SpooledTemporaryFile(mode='w+')

    # Correct null bytes in the input file ... these should be quotes??
    with open(fn, 'r') as fh_in:
        while True:
            chunk = fh_in.read(1024)
            if not chunk:
                break
            fh_tmp_in.write(chunk.replace('\0', '"'))

    # Now read the byte-corrected file as CSV and write out fixed cols.
    fh_tmp_in.seek(0)
    rdr_in = csv.reader(fh_tmp_in)
    rdr_out = csv.writer(fh_out)
    headers = []
    ncol = cols * 2 
    hcol = cols
    for i, line in enumerate(rdr_in):
        # Detect headers if necessary
        if not headers:
            headers = line[:hcol]
            rdr_out.writerow(headers)
        if len(line) != ncol:
            print("Warning! Line {} has wrong number of rows! "
                  "{}, expected {}. Truncating this row.".format(
                      i, len(line), ncol), file=sys.stderr)
        rdr_out.writerow(line[hcol:ncol])
    
    # Move to the real location.
    real_fn = os.path.join(out_dir, os.path.basename(fn))
    with open(real_fn, 'w') as fh:
        fh_out.seek(0)
        shutil.copyfileobj(fh_out, fh)

    fh_out.close()
    fh_tmp_in.close()



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw", required=True, help="Path to raw CAD files")
    parser.add_argument("--out", required=True, help="Output directory")
    parser.add_argument("--cols", type=int, default=15,
                        help="Number of real columns to parse")
    args = parser.parse_args()

    if not os.path.exists(args.out):
        raise RuntimeError("Output directory {} does not exist".format(args.out))

    files = get_raw_file_list(args.raw)
    print("Found {} files to process.".format(len(files)))
    
    for i, fn in enumerate(files):
        print("Processing ({}) {} ...".format(i + 1, fn))
        process_file(fn, args.out, args.cols)
    print("Done!")


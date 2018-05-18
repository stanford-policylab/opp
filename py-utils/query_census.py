import argparse
import census
import us
import sys


def parse_args(argv):
    parser = argparse.ArgumentParser(prog=argv[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('state')
    parser.add_argument('city')
    return parser.parse_args(argv[1:])

if __name__ == '__main__':
    args = parse_args(sys.argv)

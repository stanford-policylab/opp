# Michigans csv export did not contain quotations, so we have to manually
# impute them. Luckily only two fields (VoidReason and Description) seem
# to have the issue. Sometimes there are also spurrious new lines.

import os
import sys
import csv
import re

fn_in = '../data/states/mi/statewide/raw_csv/data.csv'
#fn_in = 'MI/MI_original_raw/head.csv'
fn_out = '../data/states/mi/statewide/calculated_features/data.csv'

# open reader connection
f_in = open(fn_in, 'rb')
reader = csv.reader(f_in, delimiter=',')
# open writer connection
f_out = open(fn_out, 'wb')
writer = csv.writer(f_out, delimiter=',', quoting=csv.QUOTE_MINIMAL)

# regex to find amount column
re_amount = re.compile(r'-?\d{1,3}\.00')

# helper function to get non-NA lines
def next(reader):
	line = ''
	while len(line) < 10:
		line = reader.next()
	return line

# iterate rows
i = 1
while True:
	try:
		row = reader.next()
	except StopIteration:
		break
	if len(row) != 167:
		print i, len(row)
		# Hypothesis 1 : spurrious new lines, try three times
		if len(row) < 167:
			row = row + reader.next()
			if len(row) < 167: row = row + next(reader)
			if len(row) < 167: row = row + next(reader)
			if len(row) < 167: row = row + next(reader)
		# Hypothesis 2 : problem in VoidReason, manually written commas
		if row[66][:2] != 'MI':
			last_id = 66 + len(row) - 167
			row = row[:65] + [','.join(row[65:last_id])] + row[last_id:]

		if i == 485957:
			print row
			print next(reader)
		# Hypothesis 3 : problem in Description , some hard-coded values have commas
		if not re_amount.match(row[131]):
			# find the index of the amount column
			j = 0
			for em in row[130:135]:
				if re_amount.match(em):
					break
				j += 1
			# combine together the n-fields to be combined
			row = row[:130] + [','.join(row[130:130+j-1])] + row[130+j:]
		# Left over problems
		if len(row) != 167:
			print i, len(row),
			print '????'
			print row[130:135]
	writer.writerow(row)
	i = i + 1
# close file connections
f_in.close()
f_out.close()

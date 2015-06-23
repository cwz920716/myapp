#! /usr/bin/python

import sys
from datetime import datetime

def diffTimePoints(a, b):
	asec = a.hour * 3600 + a.minute * 60 + a.second
	bsec = b.hour * 3600 + b.minute * 60 + b.second
	c = (asec * 1000 + a.microsecond) - (bsec * 1000 + b.microsecond)
	return c

file = open(sys.argv[1], "r")

for lines in file:
	if lines[0] == '#':
		continue
	# print lines
	tuples = lines.split()
	if len(tuples) < 7:
		continue
	timestr = tuples[0] + ' ' + tuples[1]
	# print timestr
	timepoint = datetime.strptime(timestr, '%Y-%m-%d %H:%M:%S.%f')
	direction = tuples[6]
	if direction == '>' :
		lasttp = timepoint
	else :
		print diffTimePoints(timepoint, lasttp)

file.close()

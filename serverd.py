#! /usr/bin/python

import sys
from datetime import datetime

def diffTimePoints(a, b):
	asec = a.hour * 3600 + a.minute * 60 + a.second
	bsec = b.hour * 3600 + b.minute * 60 + b.second
	c = (asec * 1000 + a.microsecond) - (bsec * 1000 + b.microsecond)
	if c < 0:
		c = 0
	return float(c)/1000.0

file = open(sys.argv[1], "r")

for lines in file:
	if lines[0] == '#':
		continue
	# print lines
	tuples = lines.split()
	if len(tuples) < 7:
		continue
	timestr = tuples[0] + ' ' + tuples[1]
	timepoint = datetime.strptime(timestr, '%Y-%m-%d %H:%M:%S.%f')
	direction = tuples[6]
	if direction == '>' :
		lasttpstr = timestr
		lasttp = timepoint
	else :
		print lasttpstr, ' ', timestr, ' ', diffTimePoints(timepoint, lasttp)

file.close()

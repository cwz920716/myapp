#! /usr/bin/python

import sys
from datetime import datetime

def sameTime(a, b):
	asec = a.hour * 3600 + a.minute * 60 + a.second
	bsec = b.hour * 3600 + b.minute * 60 + b.second
	if asec == bsec:
		return True
	else:
		return False

toplog = open(sys.argv[1], "r")
refstr = sys.argv[2]
reftp = datetime.strptime(refstr, '%Y-%m-%d %H:%M:%S.%f')

for lines in toplog:
	if lines[0] == '#':
		continue
	# print lines
	tuples = lines.split()
	if len(tuples) < 3:
		continue
	timestr = tuples[0]
	timepoint = datetime.strptime(timestr, '%H:%M:%S')
	cpu = float(tuples[1])
	if sameTime(reftp, timepoint) :
		print cpu

toplog.close()

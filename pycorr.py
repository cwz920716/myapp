#! /usr/bin/python

import sys
from datetime import datetime

def sameSecond(a, b):
	asec = a.hour * 3600 + a.minute * 60 + a.second
	bsec = b.hour * 3600 + b.minute * 60 + b.second
	if asec == bsec:
		return True
	else:
		return False

def sameMicroSecond(seq, micro):
        diff = seq - micro
	if diff < 0:
		diff = -diff
	if diff <= 40000:
                return True
        else:
                return False

toplog = open(sys.argv[1], "r")
refstr = sys.argv[2] + " " + sys.argv[3]
reftp = datetime.strptime(refstr, '%Y-%m-%d %H:%M:%S.%f')
sum = 0
seq = 0

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
	if sameSecond(reftp, timepoint) :
		seq = seq + 1
		# print cpu
		sum = sum + cpu

print 'sum=',sum
print seq

toplog.close()

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

# queue counter: The counter for measuring how many http requests are on the fly
qcnt = 0
linecnt = 0

LTPMap = {}
LTPStringMap = {}

for lines in file:
	if lines[0] == '#':
		continue
	# print lines
	linecnt = linecnt + 1
	tuples = lines.split()
	if len(tuples) < 7:
		continue
	port0 = tuples[3]
	port1 = tuples[5]
	timestr = tuples[0] + ' ' + tuples[1]
	timepoint = datetime.strptime(timestr, '%Y-%m-%d %H:%M:%S.%f')
	direction = tuples[6]
	if direction == '>' :
		sendport = port0
		LTPStringMap[sendport] = timestr
		LTPMap[sendport] = timepoint
		qcnt = qcnt + 1
		print 'queue\t', linecnt, '\t', qcnt
	else :
		sendport = port1
		print LTPStringMap[sendport], ' ', timestr, ' ', diffTimePoints(timepoint, LTPMap[sendport])
		qcnt = qcnt - 1
		print 'queue\t', linecnt, '\t', qcnt

file.close()

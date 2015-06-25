#! /bin/sh

cat ~/sdelay-500rps.txt | sort -g -k 5 | awk '{print $1, $2}' | awk '{print "python ~/myapp/pycorr.py ~/top-500rps.txt", $0}' | awk '{system($0)}'

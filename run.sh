#! /bin/sh -e

q=100
n=100

for i in $(seq 1 $q) ; do
  for j in $(seq 1 $n) ; do
    nodejs webc.js 1 | grep Delay 
  done
done

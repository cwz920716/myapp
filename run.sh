#! /bin/sh -e

rps=3100
c=100

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 [DESTDIR]" >&2
  exit 1
fi

for i in 100 1200 5000 ; do
  for j in 1 10 50 100 ; do
    ./rpsrun.sh $i $j $1
  done
done

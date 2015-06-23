#! /bin/sh

cd ~/myapp

echo 'killall node...'
ssh arldcn3 'sudo killall node'

sleep 2

echo 'killall sar...'
ssh arldcn3 'killall sar'
echo 'killall top...'
ssh arldcn3 'killall top'
echo 'killall httpry...'
ssh arldcn3 'sudo killall httpry'

sleep 3

echo 'start webserver...'
ssh -f arldcn3 "node myapp/webserver.js > node-${1}rps.txt &"

sleep 1

echo "start sar..."
ssh -f arldcn3 "sar 1 120 > sar-${1}rps.txt"
echo "start top..."
ssh -f arldcn3 "pgrep -f node"
ssh -f arldcn3 "top -bn 1200 -d 0.1 -p \$(pgrep -o -f node) | awk -f myapp/topfilter.awk > top-${1}rps.txt"
echo 'start httpry...'
ssh -f arldcn3 "sudo httpry -i eth3 'port 3000' -o httpry-${1}rps.txt"

sleep 1

echo 'start wrk...'
~/wrk2/wrk -t1 -c1 -d60s -R${1} --latency http://10.3.3.1:3000/query?qid=1 | awk -f ~/myapp/wrkfilter.awk > ~/baseline-${1}rps-remote.txt

sleep 60
echo "bye..."

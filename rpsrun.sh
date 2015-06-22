#! /bin/sh

echo 'killall...'
ssh arldcn3 'killall node'

sleep 2

echo 'killall top...'
ssh arldcn3 'killall top'
echo 'killall ...'
ssh arldcn3 'sudo killall httpry'

sleep 5

echo "start top..."
ssh -f arldcn3 "top -bn 120000 -d 0.001 | grep '^Cpu.s.' | awk -f 'toppp.awk' > top-${1}rps.txt"
echo 'start httpry...'
ssh arldcn3 "sudo httpry -i eth3 'port 3000' -o httpry-${1}rps.txt"

sleep 2

echo 'serv started...'
.wrk2/wrk -t1 -c1 -d120s -R${i} --latency http://10.3.3.1:3000/query?qid=-1 | awk -f wrkfilter.awk > baseline-${1}rps-remote.txt



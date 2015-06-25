#! /bin/sh

cd ~/myapp

mkdir -p /tmp/lb

echo 'killall node...'
ssh arldcn3 'sudo killall node'

sleep 2

echo 'killall top...'
ssh arldcn3 'killall top'
echo 'killall httpry...'
ssh arldcn3 'sudo killall httpry'

sleep 3

echo 'start webserver...'
ssh -f arldcn3 "node myapp/webserver.js > /tmp/lb/node-${1}rps-${2}conn.txt &"

sleep 1

echo "start top..."
ssh -f arldcn3 "top -bn 800 -d 0.1 -p \$(pgrep -o -f node) | awk -f myapp/topfilter.awk > /tmp/lb/top-${1}rps-${2}conn.txt"
echo 'start httpry...'
ssh arldcn3 "sudo rm /tmp/lb/httpry-${1}rps-${2}conn.txt"
ssh -f arldcn3 "sudo httpry -i eth3 'port 3000' -o /tmp/lb/httpry-${1}rps-${2}conn.txt"
sudo killall httpry
sudo rm ~/cli-httpry-${1}rps-${2}conn.txt
sudo httpry -i eth3 'port 3000' -o /tmp/lb/cli-httpry-${1}rps-${2}conn.txt &

sleep 1

echo 'start wrk...'
~/wrk2/wrk -t1 -c${2} -d60s -R${1} --latency http://10.3.3.1:3000/query?qid=1 > /tmp/lb/remote-${1}rps-${2}conn.txt

sleep 25

echo 'moving...'
cd ~
cp /tmp/lb/*.txt ~/
ssh arldcn3 'sudo cp /tmp/lb/*.txt ~/' 

python myapp/serverd.py httpry-${1}rps-${2}conn.txt | grep -v 'queue' > squeue-${1}rps-${2}conn.txt
python myapp/serverd.py httpry-${1}rps-${2}conn.txt | grep 'queue' > squeue-${1}rps-${2}conn.txt
echo "bye..."


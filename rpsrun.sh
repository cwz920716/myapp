#! /bin/sh

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 [RPS] [CONN] [DESTDIR]" >&2
  exit 1
fi

cd ~/myapp

mkdir -p /tmp/lb
sudo rm /tmp/lb/*.txt
ssh arldcn3 'mkdir -p /tmp/lb'
ssh arldcn4 'mkdir -p /tmp/lb'
ssh arldcn7 'mkdir -p /tmp/lb'
ssh arldcn3 'sudo rm /tmp/lb/*.txt'
ssh arldcn4 'sudo rm /tmp/lb/*.txt'
ssh arldcn7 'sudo rm /tmp/lb/*.txt'

echo 'killall node...'
ssh arldcn1 "sudo service haproxy stop"
ssh arldcn3 'sudo killall node'
ssh arldcn4 'sudo killall node'
ssh arldcn7 'sudo killall node'

sleep 6

# echo 'killall top...'
# ssh arldcn3 'killall top'
echo 'killall httpry...'
sudo killall httpry
ssh arldcn3 'sudo killall httpry'
ssh arldcn4 'sudo killall httpry'
ssh arldcn7 'sudo killall httpry'

sleep 3

echo 'start webserver...'
ssh -f arldcn3 "node myapp/webserver.js > /tmp/lb/arldcn3-node-${1}rps-${2}conn.txt &"
ssh -f arldcn4 "node myapp/webserver.js > /tmp/lb/arldcn4-node-${1}rps-${2}conn.txt &"
ssh -f arldcn7 "node myapp/webserver.js > /tmp/lb/arldcn7-node-${1}rps-${2}conn.txt &"
ssh arldcn1 "sudo service haproxy start"

sleep 15

# echo "start top..."
# ssh -f arldcn3 "top -bn 800 -d 0.1 -p \$(pgrep -o -f node) | awk -f myapp/topfilter.awk > /tmp/lb/top-${1}rps-${2}conn.txt"
echo 'start httpry...'
ssh arldcn3 "sudo rm /tmp/lb/arldcn3-httpry-${1}rps-${2}conn.txt"
ssh arldcn4 "sudo rm /tmp/lb/arldcn4-httpry-${1}rps-${2}conn.txt"
ssh arldcn7 "sudo rm /tmp/lb/arldcn7-httpry-${1}rps-${2}conn.txt"
ssh -f arldcn3 "sudo httpry -d -i eth3 'port 3000' -o /tmp/lb/arldcn3-httpry-${1}rps-${2}conn.txt"
ssh -f arldcn4 "sudo httpry -d -i eth3 'port 3000' -o /tmp/lb/arldcn4-httpry-${1}rps-${2}conn.txt"
ssh -f arldcn7 "sudo httpry -d -i eth3 'port 3000' -o /tmp/lb/arldcn7-httpry-${1}rps-${2}conn.txt"
sudo rm /tmp/lb/cli-httpry-${1}rps-${2}conn.txt
sudo httpry -d -i eth3 'port 3000' -o /tmp/lb/cli-httpry-${1}rps-${2}conn.txt 

sleep 5

echo 'start wrk...'
~/wrk2/wrk -t${2} -c${2} -d60s -R${1} --u_latency http://10.3.1.1:3000/query?qid=1 > /tmp/lb/remote-${1}rps-${2}conn.txt

sleep 20

# echo 'killall httpry...'
# sudo killall httpry
# ssh arldcn3 'sudo killall httpry'

# sleep 5

echo 'moving...'
mkdir -p ~/$3
cd ~/$3
sudo cp /tmp/lb/*.txt ./
ssh arldcn3 "sudo cp /tmp/lb/*.txt ~/${3}/"
ssh arldcn4 "sudo cp /tmp/lb/*.txt ~/${3}/"
ssh arldcn7 "sudo cp /tmp/lb/*.txt ~/${3}/"
cp ~/myapp/*.py ./

python serverd.py arldcn3-httpry-${1}rps-${2}conn.txt 10.3.1.1 | grep -v 'queue' > arldcn3-delay-${1}rps-${2}conn.txt
python serverd.py arldcn4-httpry-${1}rps-${2}conn.txt 10.3.1.1 | grep -v 'queue' > arldcn4-delay-${1}rps-${2}conn.txt
python serverd.py arldcn7-httpry-${1}rps-${2}conn.txt 10.3.1.1 | grep -v 'queue' > arldcn7-delay-${1}rps-${2}conn.txt
python serverd.py arldcn3-httpry-${1}rps-${2}conn.txt 10.3.1.1 | grep 'queue' > arldcn3-queue-${1}rps-${2}conn.txt
python serverd.py arldcn4-httpry-${1}rps-${2}conn.txt 10.3.1.1 | grep 'queue' > arldcn4-queue-${1}rps-${2}conn.txt
python serverd.py arldcn7-httpry-${1}rps-${2}conn.txt 10.3.1.1 | grep 'queue' > arldcn7-queue-${1}rps-${2}conn.txt
python serverd.py cli-httpry-${1}rps-${2}conn.txt 10.3.17.1 | grep -v 'queue' > cli-delay-${1}rps-${2}conn.txt
python serverd.py cli-httpry-${1}rps-${2}conn.txt 10.3.17.1 | grep 'queue' > cli-queue-${1}rps-${2}conn.txt

python plot_cdf.py arldcn3-delay-${1}rps-${2}conn.txt 4 'Time(ms)'
python plot_cdf.py arldcn4-delay-${1}rps-${2}conn.txt 4 'Time(ms)'
python plot_cdf.py arldcn7-delay-${1}rps-${2}conn.txt 4 'Time(ms)'
python plot_cdf.py arldcn3-queue-${1}rps-${2}conn.txt 2 'Qsize'
python plot_cdf.py arldcn4-queue-${1}rps-${2}conn.txt 2 'Qsize'
python plot_cdf.py arldcn7-queue-${1}rps-${2}conn.txt 2 'Qsize'
python plot_cdf.py cli-delay-${1}rps-${2}conn.txt 4 'Time(ms)'

echo "bye..."


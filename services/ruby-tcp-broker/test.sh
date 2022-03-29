#!/bin/bash

# $1 Count
# $2 Window size
# $3 Host name
# $4 Port number
# $5 File name

if [ -x  $HOME/.rbenv/bin/rbenv ]; then
    # rbenv
    PATH=$HOME/.rbenv/bin:$PATH
    eval "$(rbenv init -)"
    RUBY_DISPATCHER="rbenv"
fi

cd "$(dirname "$0")"

TIME=$(date "+%Y%m%d_%H%M")

echo start $5$1_$2_$TIME.log $(date "+%M:%S")
ruby server.rb $4 > log/$5$1_$2_$TIME.lenlog &
SRVID=$!
sleep 1
ruby recv_client.rb $1 $2 $3 $4 > log/$5$1_$2_$TIME.log &
RECVID=$!
sleep 1
ruby send_client.rb $1 $2 $3 $4 &

while(true)
do
    if [ $(ps -p $RECVID | wc -l) = "1" ]; then
    break
    fi
    sleep 1
done

echo end $5$1_$2_$TIME.log $(date "+%M:%S")

kill $SRVID

ruby ../../evaluation/cal.rb log/$5$1_$2_$TIME.log 1
#ruby ~/mule/evaluation/file_cat.rb log/$4$1_$2_$3_$TIME.log log/$4$1_$2_$3_$TIME.lenlog

echo $5$1_$2_$TIME.log >> log/latest_file.log
echo $5$1_$2_$TIME.mulog >> log/latest_file.mulog
echo $5$1_$2_$TIME.lenlog >> log/latest_file.latelog

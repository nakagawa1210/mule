#!/bin/bash

# $1 Count
# $2 Data size
# $3 Window size
# $4 File name
# $5 Port number

if [ -x  $HOME/.rbenv/bin/rbenv ]; then
    # rbenv
    PATH=$HOME/.rbenv/bin:$PATH
    eval "$(rbenv init -)"
    RUBY_DISPATCHER="rbenv"
fi

cd "$(dirname "$0")"

TIME=$(date "+%Y%m%d_%H%M")

echo start $4$1_$2_$3_$TIME.log $(date "+%M:%S")
ruby server.rb $5 > log/$4$1_$2_$3_$TIME.lenlog &
SRVID=$!
sleep 1
ruby recv_client.rb $1 $2 $3 $5 > log/$4$1_$2_$3_$TIME.log &
RECVID=$!
sleep 1
ruby send_client.rb $1 $2 $3 $5 &

while(true)
do
    if [ $(ps -p $RECVID | wc -l) = "1" ]; then
    break
    fi
    sleep 1
done

echo end $4$1_$2_$3_$TIME.log $(date "+%M:%S")

kill $SRVID

ruby ../../evaluation/cal.rb log/$4$1_$2_$3_$TIME.log $2
#ruby ~/mule/evaluation/file_cat.rb log/$4$1_$2_$3_$TIME.log log/$4$1_$2_$3_$TIME.lenlog

echo $4$1_$2_$3_$TIME.log >> log/latest_file.log
echo $4$1_$2_$3_$TIME.mulog >> log/latest_file.mulog
echo $4$1_$2_$3_$TIME.lenlog >> log/latest_file.latelog

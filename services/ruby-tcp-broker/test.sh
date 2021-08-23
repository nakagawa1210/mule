#!/bin/bash
if [ -x  $HOME/.rbenv/bin/rbenv ]; then
    # rbenv
    PATH=$HOME/.rbenv/bin:$PATH
    eval "$(rbenv init -)"
    RUBY_DISPATCHER="rbenv"
fi

cd "$(dirname "$0")"

TIME=$(date "+%Y%m%d_%H%M")

echo start $4$1_$2_$3_$TIME.log $(date "+%M:%S")
ruby server.rb $1 $2 $3 > log/$4$1_$2_$3_$TIME.lenlog &
SRVID=$!
sleep 1
ruby recv_client.rb $1 $2 $3 > log/$4$1_$2_$3_$TIME.log &
sleep 1
RECVID=$!
ruby send_client.rb $1 $2 $3 &

while(true)
do
    if [ $(ps -p $RECVID | wc -l) = "1" ]; then
    break
    fi
    sleep 1
done

echo end $4$1_$2_$3_$TIME.log $(date "+%M:%S")

kill $SRVID

ruby ~/mule/evaluation/cal.rb log/$4$1_$2_$3_$TIME.log $2
ruby ~/mule/evaluation/file_cat.rb log/$4$1_$2_$3_$TIME.log log/$4$1_$2_$3_$TIME.lenlog

echo $4$1_$2_$3_$TIME.log >> log/latest_file.log
echo $4$1_$2_$3_$TIME.mulog >> log/latest_file.mulog
echo $4$1_$2_$3_$TIME.lenlog >> log/latest_file.latelog

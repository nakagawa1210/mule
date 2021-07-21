#!/bin/bash
if [ -x  $HOME/.rbenv/bin/rbenv ]; then
    # rbenv
    PATH=$HOME/.rbenv/bin:$PATH
    eval "$(rbenv init -)"
    RUBY_DISPATCHER="rbenv"
fi

cd "$(dirname "$0")"

TIME=$(date "+%Y%m%d_%H%M")

echo start $3$1_$2_$TIME.log $(date "+%M:%S")
ruby server.rb > log/$3$1_$2_$TIME.lenlog &
SRVID=$!
sleep 1
ruby recv_client.rb $1 > log/$3$1_$2_$TIME.log &
sleep 1
RECVID=$!
ruby send_client.rb $1 $2 $4 &

while(true)
do
    if [ $(ps -p $RECVID | wc -l) = "1" ]; then
    break
    fi
    sleep 1
done

echo end $3$1_$2_$TIME.log $(date "+%M:%S")

kill $SRVID

ruby cal.rb log/$3$1_$2_$TIME.log $2
ruby file_cat.rb log/$3$1_$2_$TIME.log log/$3$1_$2_$TIME.lenlog

echo $3$1_$2_$TIME.log >> log/latest_file.log
echo $3$1_$2_$TIME.mulog >> log/latest_file.mulog
echo $3$1_$2_$TIME.lenlog >> log/latest_file.latelog

#! /bin/bash
MSGS=100
PORT_NUMBER=3000
COMMUNICATION_METHOD=TCP
SEND_LANGUAGE=C
SEND_WINDOWSIZE=1
RECV_LANGUAGE=C
RECV_WINDOWSIZE=1
BROKER_LANGUAGE=C

function check_arg {
    if [ $# != 0 ]; then
        echo "Invalid argument is specified. argument:$@" 1>&2
        exit 1
    fi
}

function dump_params {
    cat <<EOF 1>&2
MSGS                    $MSGS
PORT_NUMBER             $PORT_NUMBER
COMMUNICATION_METHOD    $COMMUNICATION_METHOD
SEND_LANGUAGE           $SEND_LANGUAGE
SEND_WINDOWSIZE         $SEND_WINDOWSIZE
RECV_LANGUAGE           $RECV_LANGUAGE
RECV_WINDOWSIZE         $RECV_WINDOWSIZE
BROKER_LANGUAGE         $BROKER_LANGUAGE
EOF
}

function usage {
    cat <<EOF 1>&2
$(basename ${0}) is a tool for messagebroker performance measurement.

Usage:
    $(basename ${0}) [<options>]

Options:
    -h                         print this
    -c MSGS                    number of msgs
    -bp PORT_NUMBER            port number used by broker
    -m COMMUNICATION_METHOD    communication method. TCP or gRPC
    -sl SEND_LANGUAGE          sender language C or Ruby
    -sw SEND_WINDOWSIZE        sender windowsize
    -rl RECV_LANGUAGE          receiver language C or Ruby
    -rw RECV_WINDOWSIZE        receiver windowsize
    -bl BROKER_LANGUAGE        broker language C or Ruby
EOF
}

#参考サイト https://qiita.com/b4b4r07/items/dcd6be0bb9c9185475bb
OPT=`getopt -o hc:m: -l bp:,sl:,sw:,rl:,rw:,bl: -a -- "$@"`
if [ $? != 0 ] ; then
    exit 1
fi
eval set -- "$OPT"

while true
do
    case $1 in
        -h) usage
            shift
            ;;
        -c) MSGS=$2
            shift 2
            ;;
        -m) COMMUNICATION_METHOD=$2
            shift 2
            ;;
	    --bp) PORT_NUMBER=$2
            shift 2
            ;;
	    --sl) SEND_LANGUAGE=$2
            shift 2
            ;;
	    --sw) SEND_WINDOWSIZE=$2
            shift 2
            ;;
	    --rl) RECV_LANGUAGE=$2
            shift 2
            ;;
	    --rw) RECV_WINDOWSIZE=$2
            shift 2
            ;;
	    --bl) BROKER_LANGUAGE=$2
            shift 2
            ;;
	    --) shift
            break
            ;;
        *)  echo "Internal error!" 1>&2
            exit 1
            ;;
    esac
done

check_arg

dump_params

TIME=$(date "+%Y%m%d_%H%M")
echo start "$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log $(date "+%H:%M:%S")

if [ $COMMUNICATION_METHOD = "TCP" ]; then
    if [ $BROKER_LANGUAGE = "C" ]; then
        ./c-tcp-broker/server $PORT_NUMBER &
        SRVID=$!
    elif [ $BROKER_LANGUAGE = "Ruby" ]; then
        ruby ruby-tcp-broker/server.rb $PORT_NUMBER &
        SRVID=$!
    else
        echo "Broker Language argument invalid value"
    fi
    sleep 1
    if [ $RECV_LANGUAGE = "C" ]; then
        ./c-tcp-broker/recv_client $MSGS 1 $RECV_WINDOWSIZE $PORT_NUMBER > log/"$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log &
        RECVID=$!
    elif [ $RECV_LANGUAGE = "Ruby" ]; then
        ruby ruby-tcp-broker/recv_client.rb > log/"$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log &
        RECVID=$!
    else
        echo "Receiver Language argument invalid value"
    fi
    sleep 1
    if [ $SEND_LANGUAGE = "C" ]; then
        ./c-tcp-broker/send_client $MSGS 1 $SEND_WINDOWSIZE $PORT_NUMBER
    elif [ $SEND_LANGUAGE = "Ruby" ]; then
        ruby ruby-tcp-broker/send_client.rb $MSGS 1 $SEND_WINDOWSIZE $PORT_NUMBER
    else
        echo "Sender Language argument invalid value"
    fi
elif [ $COMMUNICATION_METHOD = "gRPC" ]; then
    if [ $BROKER_LANGUAGE = "C" ]; then
        ./c-grpc-broker/server $PORT_NUMBER &
        SRVID=$!
    elif [ $BROKER_LANGUAGE = "Ruby" ]; then
        ruby ruby-grpc-broker/server.rb $PORT_NUMBER &
        SRVID=$!
    else
        echo "Broker Language argument invalid value"
    fi
    sleep 1
    if [ $RECV_LANGUAGE = "C" ]; then
        ./c-grpc-broker/recv_client $MSGS 1 $RECV_WINDOWSIZE $PORT_NUMBER > log/"$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log &
        RECVID=$!
    elif [ $RECV_LANGUAGE = "Ruby" ]; then
        ruby ruby-grpc-broker/recv_client.rb $MSGS 1 $RECV_WINDOWSIZE $PORT_NUMBER > log/"$MSGS"_"$COMMUNICATION_METHOD"-$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log &
        RECVID=$!
    else
        echo "Receiver Language argument invalid value"
    fi
    sleep1
    if [ $SEND_LANGUAGE = "C" ]; then
        ./c-grpc-broker/send_client $MSGS 1 $SEND_WINDOWSIZE $PORT_NUMBER
    elif [ $SEND_LANGUAGE = "Ruby" ]; then
        ruby ruby-grpc-broker/send_client.rb $MSGS 1 $SEND_WINDOWSIZE $PORT_NUMBER
    else
        echo "Sender Language argument invalid value"
    fi
else
    echo "Communication Method argument invalid value"
fi

while(true)
do
    if [ $(ps -p $RECVID | wc -l) = "1" ]; then
    break
    fi
    sleep 1
done

kill $SRVID
echo end "$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log $(date "+%H:%M:%S")

echo "$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log >> log/latest_file.log

#! /bin/bash
MSGS=100
HOST_NAME=localhost
PORT_NUMBER=3000
COMMUNICATION_METHOD=TCP
SEND_LANGUAGE=C
SEND_WINDOWSIZE=1
RECV_LANGUAGE=C
RECV_WINDOWSIZE=1
BROKER_LANGUAGE=C
SEND_NUMBER=1
RECV_NUMBER=1

function check_arg {
    if [ $# != 0 ]; then
        echo "Invalid argument is specified. argument:$@" 1>&2
        exit 1
    fi
}

function dump_params {
    cat <<EOF 1>&2
MSGS                    $MSGS
HOST_NAME		$HOST_NAME
PORT_NUMBER             $PORT_NUMBER
COMMUNICATION_METHOD    $COMMUNICATION_METHOD
SEND_LANGUAGE           $SEND_LANGUAGE
SEND_WINDOWSIZE         $SEND_WINDOWSIZE
SEND_NUMBER             $SEND_NUMBER
RECV_LANGUAGE           $RECV_LANGUAGE
RECV_WINDOWSIZE         $RECV_WINDOWSIZE
RECV_NUMBER             $RECV_NUMBER
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
    -bh HOST_NAME	       host name of broker
    -bp PORT_NUMBER            port number used by broker
    -m COMMUNICATION_METHOD    communication method. TCP or gRPC
    -sl SEND_LANGUAGE          sender language C or Ruby
    -sw SEND_WINDOWSIZE        sender windowsize
    -rl RECV_LANGUAGE          receiver language C or Ruby
    -rw RECV_WINDOWSIZE        receiver windowsize
    -bl BROKER_LANGUAGE        broker language C or Ruby
    -sn SEND_NUMBER            number of sender
    -rn RECV_NUMBER            number of receiver
EOF
}

#参考サイト https://qiita.com/b4b4r07/items/dcd6be0bb9c9185475bb
OPT=`getopt -o hc:m: -l bh:,bp:,sl:,sw:,rl:,rw:,bl:,sn:,rn: -a -- "$@"`
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
	--bh) HOST_NAME=$2
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
	--sn) SEND_NUMBER=$2
            shift 2
            ;;
	--rn) RECV_NUMBER=$2
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

SEND_MSGS=$(expr $MSGS / $SEND_NUMBER)
RECV_MSGS=$(expr $MSGS / $RECV_NUMBER)
RECVID=()

if [ $COMMUNICATION_METHOD = "TCP" ]; then
    if [ $HOST_NAME != "localhost" ]; then
	if [ $BROKER_LANGUAGE = "C" ]; then
            ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/server $PORT_NUMBER &
	elif [ $BROKER_LANGUAGE = "Ruby" ]; then
            ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby mule/services/ruby-tcp-broker/server.rb $PORT_NUMBER &
	else
            echo "Broker Language argument invalid value"
	fi
    else
	if [ $BROKER_LANGUAGE = "C" ]; then
            ./c-tcp-broker/server $PORT_NUMBER &
            SRVID=$!
	elif [ $BROKER_LANGUAGE = "Ruby" ]; then
            ruby ruby-tcp-broker/server.rb $PORT_NUMBER &
            SRVID=$!
	else
            echo "Broker Language argument invalid value"
	fi
    fi
    
    sleep 1
    
    if [ $RECV_LANGUAGE = "C" ]; then
	for i in $(seq 1 $RECV_NUMBER)
	do
	    ./c-tcp-broker/recv_client $RECV_MSGS $RECV_WINDOWSIZE $HOST_NAME $PORT_NUMBER > log/"$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_"$TIME"_$i.log &
            RECVID+=($!)
	done
    elif [ $RECV_LANGUAGE = "Ruby" ]; then
	for i in $(seq 1 $RECV_NUMBER)
	do
	    ruby ruby-tcp-broker/recv_client.rb $RECV_MSGS $RECV_WINDOWSIZE $HOST_NAME $PORT_NUMBER > log/"$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_"$TIME"_$i.log &
            RECVID+=($!)
	done    
    else
        echo "Receiver Language argument invalid value"
    fi

    sleep 1

    if [ $SEND_LANGUAGE = "C" ]; then
	for i in $(seq 1 $SEND_NUMBER)
	do
	    ./c-tcp-broker/send_client $SEND_MSGS $SEND_WINDOWSIZE $HOST_NAME $PORT_NUMBER
	done		 
    elif [ $SEND_LANGUAGE = "Ruby" ]; then
	for i in $(seq 1 $SEND_NUMBER)
	do
            ruby ruby-tcp-broker/send_client.rb $SEND_MSGS $SEND_WINDOWSIZE $HOST_NAME $PORT_NUMBER
	done
    else
        echo "Sender Language argument invalid value"
    fi
    
elif [ $COMMUNICATION_METHOD = "gRPC" ]; then
    if [ $HOST_NAME != "localhost" ]; then
	if [ $BROKER_LANGUAGE = "C" ]; then
            ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-grpc-broker/server $PORT_NUMBER &
	elif [ $BROKER_LANGUAGE = "Ruby" ]; then
            ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby mule/services/ruby-grpc-broker/server.rb $PORT_NUMBER &
	else
            echo "Broker Language argument invalid value"
	fi
    else
	if [ $BROKER_LANGUAGE = "C" ]; then
            ./c-grpc-broker/server $PORT_NUMBER &
            SRVID=$!
	elif [ $BROKER_LANGUAGE = "Ruby" ]; then
            ruby ruby-grpc-broker/server.rb $PORT_NUMBER &
            SRVID=$!
	else
            echo "Broker Language argument invalid value"
	fi
    fi
    
    sleep 1
    
    if [ $RECV_LANGUAGE = "C" ]; then
	for i in $(seq 1 $RECV_NUMBER)
	do
            ./c-grpc-broker/recv_client $MSGS $RECV_WINDOWSIZE $HOST_NAME $PORT_NUMBER > log/"$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_"$TIME"_$i.log &
            RECVID+=($!)
	done
    elif [ $RECV_LANGUAGE = "Ruby" ]; then
	for i in $(seq 1 $RECV_NUMBER)
	do
            ruby ruby-grpc-broker/recv_client.rb $MSGS $RECV_WINDOWSIZE $HOST_NAME $PORT_NUMBER > log/"$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_"$TIME"_$i.log &
            RECVID+=($!)
	done
    else
        echo "Receiver Language argument invalid value"
    fi
    
    sleep1
    
    if [ $SEND_LANGUAGE = "C" ]; then
	for i in $(seq 1 $SEND_NUMBER)
	do
            ./c-grpc-broker/send_client $SEND_MSGS $SEND_WINDOWSIZE $HOST_NAME $PORT_NUMBER
	done
    elif [ $SEND_LANGUAGE = "Ruby" ]; then
	for i in $(seq 1 $SEND_NUMBER)
	do
            ruby ruby-grpc-broker/send_client.rb $SEND_MSGS $SEND_WINDOWSIZE $HOST_NAME $PORT_NUMBER
	done
    else
        echo "Sender Language argument invalid value"
    fi
else
    echo "Communication Method argument invalid value"
fi

wait ${RECVID[@]}

for i in $(seq 1 $RECV_NUMBER)
do
    cat log/"$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_"$TIME"_$i.log  >> log/"$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log
done

if [ $HOST_NAME != "localhost" ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp killall server
else
    kill $SRVID
fi

echo end "$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log $(date "+%H:%M:%S")

echo "$MSGS"_"$COMMUNICATION_METHOD"_$SEND_WINDOWSIZE-$SEND_LANGUAGE-$RECV_WINDOWSIZE-$RECV_LANGUAGE-"$BROKER_LANGUAGE"_$TIME.log >> log/latest_file.log

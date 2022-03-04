#! /bin/bash
MSGS=100
PORT_NUMBER=3000
COMMUNICATION_METHOD=TCP
SEND_LANGUAGE=C
SEND_WINDOWSIZE=1
RECV_LANGUAGE=C
RECV_WINDOWSIZE=1
BROKER_LANGUAGE=C

function usage {
    cat <<EOF
$(basename ${0}) is a tool for ...

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
	    echo "-c $MSGS"
            shift 2
            ;;
        -m) COMMUNICATION_METHOD=$2
	    echo "-m $COMMUNICATION_METHOD"
            shift 2
            ;;
	--bp) PORT_NUMBER=$2
	    echo "-bp $PORT_NUMBER"
            shift 2
            ;;
	--sl) SEND_LANGUAGE=$2
	    echo"-sl $SEND_LANGUAGE"
            shift 2
            ;;
	--sw) SEND_WINDOWSIZE=$2
	    echo "-sw $SEND_WINDOWSIZE"
            shift 2
            ;;
	--rl) RECV_LANGUAGE=$2
	    echo "-rl $RECV_LANGUAGE"
            shift 2
            ;;
	--rw) RECV_WINDOWSIZE=$2
	    echo "-rw $RECV_WINDOWSIZE"
            shift 2
            ;;
	--bl) BROKER_LANGUAGE=$2
	    echo "-bl $BROKER_LANGUAGE"
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


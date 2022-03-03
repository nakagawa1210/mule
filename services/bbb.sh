#! /bin/bash
OPT=`getopt -o hc:m: -l bp:,sl:,sw:,rl:,rw:,bl: -a -- "$@"`
if [ $? != 0 ] ; then
    exit 1
fi
eval set -- "$OPT"

while true
do
    case $1 in
        -h) echo "-h"
            shift
            ;;
        -c) C_ARG=$2
	    echo "-c $C_ARG"
            shift 2
            ;;
        -m) M_ARG=$2
	    echo "-m $M_ARG"
            shift 2
            ;;
	--bp) BP_ARG=$2
	    echo "-bp $BP_ARG"
            shift 2
            ;;
	--sl) SL_ARG=$2
	    echo"-sl $BP_ARG"
            shift 2
            ;;
	--sw) SW_ARG=$2
	    echo "-sw $SW_ARG"
            shift 2
            ;;
	--rl) RL_ARG=$2
	    echo "-rl $RL_ARG"
            shift 2
            ;;
	--rw) RW_ARG=$2
	    echo "-rw $RW_ARG"
            shift 2
            ;;
	--bl) BL_ARG=$2
	    echo "-bl $BL_ARG"
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


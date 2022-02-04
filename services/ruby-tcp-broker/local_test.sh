#!/bin/bash

if [ "$1" = "" ] ; then
    MIN=1
else
    MIN=$1
fi
if [ "$2" = "" ] ; then
    MAX=100000
else
    MAX=$2
fi
if [ "$3" = "" ] ; then
    MS=1
else
    MS=$3
fi

echo delete latestlog
:>| log/latest_file.log
:>| log/latest_file.mulog
:>| log/latest_file.latelog

if [ $MIN -le 100000 ] && [ $MAX -ge 100000 ]; then
    ./test.sh 100000 1 100000 local_tcp_win100000_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2  100000 local_tcp_win100000_ 10005
    fi
    if [ $MS -ge 4 ]; then
    ./test.sh 100000 4  100000 local_tcp_win100000_ 10005
    fi
fi

if [ $MIN -le 50000 ] && [ $MAX -ge 50000 ]; then
    ./test.sh 100000 1 50000 local_tcp_win50000_ 10005
    if [ $MS -ge 2 ]; then
	    ./test.sh 100000 2 50000 local_tcp_win50000_ 10005
	fi
	if [ $MS -ge 4 ]; then
	    ./test.sh 100000 4 50000 local_tcp_win50000_ 10005
	fi
fi

if [ $MIN -le 20000 ] && [ $MAX -ge 20000 ]; then
    ./test.sh 100000 1  20000 local_tcp_win20000_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2  20000 local_tcp_win20000_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 20000 local_tcp_win20000_ 10005
    fi
fi

if [ $MIN -le 10000 ] && [ $MAX -ge 10000 ]; then
    ./test.sh 100000 1 10000 local_tcp_win10000_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 10000 local_tcp_win10000_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 10000 local_tcp_win10000_ 10005
    fi
fi

if [ $MIN -le 5000 ] && [ $MAX -ge 5000 ]; then
    ./test.sh 100000 1 5000 local_tcp_win5000_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 5000 local_tcp_win5000_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 5000 local_tcp_win5000_ 10005
    fi
fi

if [ $MIN -le 2000 ] && [ $MAX -ge 2000 ]; then
    ./test.sh 100000 1 2000 local_tcp_win2000_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 2000 local_tcp_win2000_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4  2000 local_tcp_win2000_ 10005
    fi
fi

if [ $MIN -le 1000 ] && [ $MAX -ge 1000 ]; then
    ./test.sh 100000 1 1000 local_tcp_win1000_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 1000 local_tcp_win1000_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 1000 local_tcp_win1000_ 10005
    fi
fi

if [ $MIN -le 500 ] && [ $MAX -ge 500 ]; then
    ./test.sh 100000 1 500 local_tcp_win500_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 500 local_tcp_win500_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 500 local_tcp_win500_ 10005
    fi
fi

if [ $MIN -le 200 ] && [ $MAX -ge 200 ]; then
    ./test.sh 100000 1 200 local_tcp_win200_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 200 local_tcp_win200_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4  200 local_tcp_win200_ 10005
    fi
fi

if [ $MIN -le 100 ] && [ $MAX -ge 100 ]; then
    ./test.sh 100000 1 100 local_tcp_win100_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 100 local_tcp_win100_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 100 local_tcp_win100_ 10005
    fi
fi

if [ $MIN -le 50 ] && [ $MAX -ge 50 ]; then
    ./test.sh 100000 1 50 local_tcp_win50_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 50 local_tcp_win50_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 50 local_tcp_win50_ 10005
    fi
fi

if [ $MIN -le 20 ] && [ $MAX -ge 20 ]; then
    ./test.sh 100000 1 20 local_tcp_win20_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 20 local_tcp_win20_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 20 local_tcp_win20_ 10005
    fi
fi

if [ $MIN -le 10 ] && [ $MAX -ge 10 ]; then
    ./test.sh 100000 1 10 local_tcp_win10_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 10 local_tcp_win10_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 10 local_tcp_win10_ 10005
    fi
fi

if [ $MIN -le 5  ] && [ $MAX -ge 5  ]; then
    ./test.sh 100000 1 5 local_tcp_win5_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 5 local_tcp_win5_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 5 local_tcp_win5_ 10005
    fi
fi

if [ $MIN -le 2  ] && [ $MAX -ge 2  ]; then
    ./test.sh 100000 1 2 local_tcp_win2_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 2 local_tcp_win2_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 2 local_tcp_win2_ 10005
    fi
fi

if [ $MIN -le 1  ] && [ $MAX -ge 1  ]; then
    ./test.sh 100000 1 1 local_tcp_win1_ 10005
    if [ $MS -ge 2 ]; then
	./test.sh 100000 2 1 local_tcp_win1_ 10005
    fi
    if [ $MS -ge 4 ]; then
	./test.sh 100000 4 1 local_tcp_win1_ 10005
    fi
fi

if [ $MIN -le 0  ] && [ $MAX -ge 0  ]; then
    ./ws_test.sh 100000 1 1 1 local_tcp_win1-1_ 10005
    ./ws_test.sh 100000 1 1 2 local_tcp_win1-2_ 10005
    ./ws_test.sh 100000 1 1 3 local_tcp_win1-3_ 10005
    ./ws_test.sh 100000 1 1 4 local_tcp_win1-4_ 10005
    ./ws_test.sh 100000 1 1 5 local_tcp_win1-5_ 10005
fi

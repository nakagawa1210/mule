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

make

echo delete latestlog
~/mule/evaluation/clean_latestlog.sh c-tcp-broker

echo rsync
rsync --delete --archive ~/mule/services/c-tcp-broker/ nakagawa@hsc1.swlab.cs.okayama-u.ac.jp:mule/services/c-tcp-broker

if [ $MIN -le 100000 ] && [ $MAX -ge 100000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 100000 ssh_tcp_win100000 10000
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 100000 ssh_tcp_win100000 10001
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 100000 ssh_tcp_win100000 10002
    fi
    
fi

if [ $MIN -le 50000 ] && [ $MAX -ge 50000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 50000 ssh_tcp_win50000 10004
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 50000 ssh_tcp_win50000 10005
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 50000 ssh_tcp_win50000 10006
    fi
fi

if [ $MIN -le 20000 ] && [ $MAX -ge 20000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 20000 ssh_tcp_win20000 10007
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 20000 ssh_tcp_win20000 10008
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 20000 ssh_tcp_win20000 10009
    fi
fi

if [ $MIN -le 10000 ] && [ $MAX -ge 10000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 10000 ssh_tcp_win10000 10010
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 10000 ssh_tcp_win10000 10011
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 10000 ssh_tcp_win10000 10012
    fi
fi

if [ $MIN -le 5000 ] && [ $MAX -ge 5000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 5000 ssh_tcp_win5000 10013
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 5000 ssh_tcp_win5000 10014
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 5000 ssh_tcp_win5000 10015
    fi
fi

if [ $MIN -le 2000 ] && [ $MAX -ge 2000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 2000 ssh_tcp_win2000 10016
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 2000 ssh_tcp_win2000 10017
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 2000 ssh_tcp_win2000 10018
    fi
fi

if [ $MIN -le 1000 ] && [ $MAX -ge 1000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 1000 ssh_tcp_win1000 10019
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 1000 ssh_tcp_win1000 10020
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 1000 ssh_tcp_win1000 10021
    fi
fi

if [ $MIN -le 500 ] && [ $MAX -ge 500 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 500 ssh_tcp_win500 10022
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 500 ssh_tcp_win500 10023
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 500 ssh_tcp_win500 10024
    fi
fi

if [ $MIN -le 200 ] && [ $MAX -ge 200 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 200 ssh_tcp_win200 10025
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 200 ssh_tcp_win200 10026
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 200 ssh_tcp_win200 10027
    fi
fi

if [ $MIN -le 100 ] && [ $MAX -ge 100 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 100 ssh_tcp_win100 10028
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 100 ssh_tcp_win100 10029
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 100 ssh_tcp_win100 10030
    fi
fi

if [ $MIN -le 50 ] && [ $MAX -ge 50 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 50 ssh_tcp_win50 10031
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 50 ssh_tcp_win50 10032
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 50 ssh_tcp_win50 10033
    fi
fi

if [ $MIN -le 20 ] && [ $MAX -ge 20 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 20 ssh_tcp_win20 10034
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 20 ssh_tcp_win20 10035
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 20 ssh_tcp_win20 10036
    fi
fi

if [ $MIN -le 10 ] && [ $MAX -ge 10 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 10 ssh_tcp_win10 10037
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 10 ssh_tcp_win10 10038
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 10 ssh_tcp_win10 10039
    fi
fi

if [ $MIN -le 5  ] && [ $MAX -ge 5  ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 5 ssh_tcp_win5 10040
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 5 ssh_tcp_win5 10041
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 5 ssh_tcp_win5 10042
    fi
fi

if [ $MIN -le 2  ] && [ $MAX -ge 2  ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 2 ssh_tcp_win2 10043
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 2 ssh_tcp_win2 10044
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 2 ssh_tcp_win2 10045
    fi
fi

if [ $MIN -le 1  ] && [ $MAX -ge 1  ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 1 1 ssh_tcp_win1 10046
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 2 1 ssh_tcp_win1 10047
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp mule/services/c-tcp-broker/test.sh 100000 4 1 ssh_tcp_win1 10048
    fi
fi

echo rsync
rsync --delete --archive nakagawa@hsc1.swlab.cs.okayama-u.ac.jp:mule/services/c-tcp-broker/log/ log/


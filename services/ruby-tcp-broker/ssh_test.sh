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
./clean_latestlog.sh

echo rsync
rsync --delete --archive ~/ruby_broker/ nakagawa@hsc1.swlab.cs.okayama-u.ac.jp:ruby_broker/


if [ $MIN -le 100000 ] && [ $MAX -ge 100000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win100000_ 100000
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win100000_ 100000
    fi
    if [ $MS -ge 4 ]; then
       ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win100000_ 100000
    fi
fi

if [ $MIN -le 50000 ] && [ $MAX -ge 50000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win50000_ 50000
        if [ $MS -ge 2 ]; then
	    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win50000_ 50000
	fi
	if [ $MS -ge 4 ]; then
	    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win50000_ 50000
	fi
fi

if [ $MIN -le 20000 ] && [ $MAX -ge 20000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win20000_ 20000
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win20000_ 20000
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win20000_ 20000
    fi
fi

if [ $MIN -le 10000 ] && [ $MAX -ge 10000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win10000_ 10000
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win10000_ 10000
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win10000_ 10000
    fi    
fi

if [ $MIN -le 5000 ] && [ $MAX -ge 5000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win5000_ 5000
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win5000_ 5000
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win5000_ 5000
    fi
fi

if [ $MIN -le 2000 ] && [ $MAX -ge 2000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win2000_ 2000
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win2000_ 2000
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win2000_ 2000
    fi
fi

if [ $MIN -le 1000 ] && [ $MAX -ge 1000 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win1000_ 1000
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win1000_ 1000
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win1000_ 1000
    fi
fi

if [ $MIN -le 500 ] && [ $MAX -ge 500 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win500_ 500
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win500_ 500
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win500_ 500
    fi
fi

if [ $MIN -le 200 ] && [ $MAX -ge 200 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win200_ 200
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win200_ 200
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win200_ 200
    fi
fi

if [ $MIN -le 100 ] && [ $MAX -ge 100 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win100_ 100
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win100_ 100
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win100_ 100
    fi
fi

if [ $MIN -le 50 ] && [ $MAX -ge 50 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win50_ 50
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win50_ 50
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win50_ 50
    fi
fi

if [ $MIN -le 20 ] && [ $MAX -ge 20 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win20_ 20
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win20_ 20
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win20_ 20
    fi
fi

if [ $MIN -le 10 ] && [ $MAX -ge 10 ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win10_ 10
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win10_ 10
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win10_ 10
    fi
fi

if [ $MIN -le 5  ] && [ $MAX -ge 5  ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win5_ 5
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win5_ 5
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win5_ 5
    fi
fi

if [ $MIN -le 2  ] && [ $MAX -ge 2  ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win2_ 2
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win2_ 2
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win2_ 2
    fi
fi

if [ $MIN -le 1  ] && [ $MAX -ge 1  ]; then
    ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win1_ 1
    if [ $MS -ge 2 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 2 ssh_tcp_win1_ 1
    fi
    if [ $MS -ge 4 ]; then
	ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 4 ssh_tcp_win1_ 1
    fi
fi

if [ $MIN -le 0  ] && [ $MAX -ge 0  ]; then
ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win100_ 100
ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win10_ 10
ssh nakagawa@hsc1.swlab.cs.okayama-u.ac.jp ruby_broker/test.sh 100000 1 ssh_tcp_win1_ 1
fi

echo rsync
rsync --delete --archive nakagawa@hsc1.swlab.cs.okayama-u.ac.jp:ruby_broker/log/ log/

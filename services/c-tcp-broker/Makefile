all: svr send recv
#recv

#mybroker

svr: server.c
	gcc server.c ../lib/message.c ../lib/network.c ../lib/timer.c -pthread -o server -std=gnu99
send: send_client.c
	gcc send_client.c ../lib/message.c ../lib/network.c ../lib/timer.c -o send_client -std=gnu99
recv: recv_client.c
	gcc recv_client.c ../lib/message.c ../lib/network.c ../lib/timer.c -o recv_client -std=gnu99


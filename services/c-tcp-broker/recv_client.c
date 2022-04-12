#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdlib.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include "../lib/message.h"
#include "../lib/network.h"
#include "../lib/timer.h"

#define MAX_COUNT 100000
#define WS_1 1

struct message msg[MAX_COUNT];
int data_num = 0;

int send_ack(int fd,
	     uint32_t msg_type,
	     uint32_t ws,
	     uint32_t saddr,
	     uint32_t daddr
	     ){
  char payload[MSG_PAYLOAD_LEN] = "Hello";

  int n = net_send_ack(fd, payload, msg_type, ws, saddr, daddr);

  return n;
}

int recv_msg(int fd,
	     uint32_t saddr,
	     uint32_t daddr){
  struct message rmsg;
  uint64_t log_tsc;

  net_recv_msg(fd, &rmsg);
  log_tsc = getclock();
  msg_assign_time_stamp(&rmsg, log_tsc, RECVER_RECV);
  msg[data_num] = rmsg;
  data_num++;

  return rmsg.hdr.fragments;
}

int recv_n_msg (int fd,
		uint32_t n,
		uint32_t saddr,
		uint32_t daddr) {
  for (int i = 0; i < n; i++){
    recv_msg(fd, saddr, daddr);
  }
  return 0;
}

void recv_msgs(int count, uint32_t win_size, char *host, int port_num){
  int fd = socket(AF_INET, SOCK_STREAM, 0);

  if (fd < 0) {
    perror("socket");
    return;
  }
  struct addrinfo hints, *res;
  struct in_addr in_addr;
  int err;
  struct sockaddr_in addr;
  
  memset(&hints, 0, sizeof(hints));
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_family = AF_INET;
  
  if ((err = getaddrinfo(host, NULL, &hints, &res)) != 0) {
    printf("error %d\n", err);
    return;
  }
  in_addr.s_addr= ((struct sockaddr_in *)(res->ai_addr))->sin_addr.s_addr;

  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port_num);
  memcpy(&addr.sin_addr, &in_addr, sizeof(in_addr));

  //struct hostent *hp;
  //if  ((hp = gethostbyname(host)) == NULL) {
  //  fprintf(stderr, "gethost error %s\n", host);
  //  close(fd);
  //  return;
  //}
  //
  //struct sockaddr_in addr;
  //memset(&addr, 0, sizeof(addr));
  //addr.sin_family = AF_INET;
  //addr.sin_port = htons(port_num);
  //memcpy(&addr.sin_addr, hp->h_addr, hp->h_length);

  while (1) {
    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
	  sleep(1);
      continue;
    } else {
      break;
    }
  }

  int on=1;
  int ret = setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &on, sizeof(on));

  char payload[MSG_PAYLOAD_LEN] = "Hello";
  uint32_t saddr = 200;
  uint32_t daddr = 100;

  struct ack_message ws_msg;
  struct ack_message ack_msg;
  int recv_count = 0;

  net_hello_req(fd, saddr, daddr);

  while(recv_count + win_size < count){
    send_ack(fd, RECV_N_REQ, win_size, saddr, daddr);
    while(1){
      if(recv_msg(fd, saddr, daddr) == 1){
	recv_count += win_size;
	break;
      }
    }
  }
  send_ack(fd, RECV_N_REQ, count - recv_count, saddr, daddr);
  recv_n_msg(fd, count - recv_count, saddr, daddr);
  send_ack(fd, RECV_ACK, WS_1, saddr, daddr);

  if (close(fd) == -1) {
    printf("%d\n", errno);
  }

  printf("num,send,svr_in,svr_out,recv\n");
  for (int i = 0; i < data_num; i++) {
    printf("%d,%lf,%lf,%lf,%lf\n",i,
	   (double)(msg[i].hdr.sender_send_time) / (1000 * 1000 * 1000),
	   (double)(msg[i].hdr.server_recv_time) / (1000 * 1000 * 1000),
	   (double)(msg[i].hdr.server_send_time) / (1000 * 1000 * 1000),
	   (double)(msg[i].hdr.recver_recv_time) / (1000 * 1000 * 1000));
  }

  return;
}

int main(int argc, char *argv[])
{
  setvbuf(stdout, (char *)NULL, _IONBF, 0);
  int count = 1;
  uint32_t win_size = 1;
  char host_name[80] = "localhost";
  int port_num = 8000;

  if(argc > 1){
    count = atoi(argv[1]);
  }else{
    printf("%s argument error count\n", __FILE__);
    return 0;
  }

  if(argc > 2){
    win_size = atoi(argv[2]);
  }else{
    printf("%s argument error win_size\n", __FILE__);
    return 0;
  }

  if(argc > 3 && sizeof(argv[3]) < 81){
    strncpy(host_name, argv[3], strlen(argv[3])+1);
  }else{
    printf("%s argument error host_name\n", __FILE__);
    return 0;
  }

  if(argc > 4){
    port_num = atoi(argv[4]);
  }else{
    printf("%s argument error port_num\n", __FILE__);
    return 0;
  }

  recv_msgs(count, win_size, host_name, port_num);

  return 0;
}

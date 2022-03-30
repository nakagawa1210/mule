#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <linux/sockios.h>
#include <netdb.h>
#include <stdlib.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include "../lib/message.h"
#include "../lib/network.h"
#include "../lib/timer.h"


#define MAX_COUNT 100000
#define WS_1 1

int recv_msg(int fd){
  struct ack_message msg_ack;

  net_recv_ack(fd, &msg_ack, SEND_ACK);

  return msg_ack.hdr.ws;
}


int send_msg (int fd,
	      uint32_t n,
	      uint32_t saddr,
	      uint32_t daddr,
	      void *payload){
  struct message smsg;
  uint64_t log_tsc;
  msg_fill(&smsg,SEND_MSG, n, saddr, daddr, payload,sizeof(payload));
  log_tsc = getclock();
  msg_assign_time_stamp(&smsg, log_tsc, SENDER_SEND);
  net_send_msg(fd, &smsg);

  return 0;
}

void send_msgs (int count, uint32_t win_size, char *host, int port_num){
  int fd = socket(AF_INET, SOCK_STREAM, 0);

  if (fd < 0) {
    perror("socket\n");
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
  //if ((hp = gethostbyname(host)) == NULL) {
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
  //
  //print_hostname(hp);
  //print_ipaddr_v4(hp);
  

  while (1) {
    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
      sleep(1);
      printf("connect\n");
      continue;
    } else {
      break;
    }
  }

  int on=1;
  int ret;
  ret = setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &on, sizeof(on));

  //int fd = net_connect(host, port_num);

  //start_send_messages
  char payload[MSG_PAYLOAD_LEN] = "Hello";
  uint32_t saddr = 100;
  uint32_t daddr = 200;
  uint32_t ws;
  uint32_t next_ws;

  int send_count = 0;

  net_hello_req(fd, saddr, daddr);

  ws = WS_1;

  while(send_count + ws < count){
    for (uint32_t i = ws; i > 0; i--) {
      send_msg(fd, i, saddr, daddr, payload);
    }
    next_ws = recv_msg(fd);
    send_count += ws;
    //ws = next_ws;
    ws = win_size;
  }
  for (uint32_t i = (count - send_count); i > 0; i--){
    send_msg(fd, i, saddr, daddr, payload);
  }
  recv_msg(fd);

  //end_sendmessages

  if (close(fd) == -1) {
    printf("%d\n", errno);
  }
}

int main (int argc, char *argv[])
{
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

  if(argc > 3 && strlen(argv[3]) < 81){
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

  send_msgs(count, win_size, host_name, port_num);
  return 0;
}

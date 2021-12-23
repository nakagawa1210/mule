#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <time.h>
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

#include "../lib/message.h"
#include "../lib/network.h"

#define rdtsc_64(lower, upper) asm __volatile ("rdtsc" : "=a"(lower), "=d" (upper));

#define PORT_NO 9999
#define MAX_COUNT 100000
#define MEM_SIZE 5000
#define WS_1 1

unsigned long int gettsc(){
  unsigned int tsc_l, tsc_u; //uint32_t

  rdtsc_64(tsc_l, tsc_u);
  return (unsigned long int)tsc_u<<32 | tsc_l;
}

int send_n_request (int fd,
		    uint32_t n,
		    uint32_t saddr,
		    uint32_t daddr,
		    void *payload){
  struct message smsg;
  uint64_t log_tsc;
  
  for (int i = 0; i < n; i++){
    if(i == n-1){
      msg_fill(&smsg,SEND_MSG_ACK, n, saddr, daddr, payload,sizeof(payload));
    }else{
      msg_fill(&smsg, SEND_MSG, n, saddr, daddr, payload, sizeof(payload));
    }
    log_tsc = gettsc();
    msg_assign_time_stamp(&smsg, log_tsc, SENDER_SEND);
    net_send_msg(fd, &smsg);
  }
  return 0;
}

int send_msg (int fd,
	      uint32_t n,
	      uint32_t saddr,
	      uint32_t daddr,
	      void *payload){
  struct message smsg;
  uint64_t log_tsc;
  msg_fill(&smsg,SEND_MSG, n, saddr, daddr, payload,sizeof(payload));
  log_tsc = gettsc();
  msg_assign_time_stamp(&smsg, log_tsc, SENDER_SEND);
  net_send_msg(fd, &smsg);
  
  return 0;
}

int send_msg_ack (int fd,
		  uint32_t saddr,
		  uint32_t daddr,
		  void *payload){
  struct message smsg;
  uint64_t log_tsc;
  msg_fill(&smsg,SEND_MSG_ACK, WS_1, saddr, daddr, payload,sizeof(payload));
  net_send_msg(fd, &smsg);
  
  return 0;
}

void send_msgs (char *host, int count, int len, uint32_t win_size, int port_num){

  int fd = socket(AF_INET, SOCK_STREAM, 0);

  if (fd < 0) {
    perror("socket\n");
    return;
  }

  struct hostent *hp;
  if ((hp = gethostbyname(host)) == NULL) {
    fprintf(stderr, "gethost error %s\n", host);
    close(fd);
    return;
  }

  struct sockaddr_in addr;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port_num);
  memcpy(&addr.sin_addr, hp->h_addr, hp->h_length);
  
  while (1) {
    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
      printf("sleep\n");
      sleep(1);
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

  struct message msg_ack;
  int send_count = 0;

  //hello_req
  struct message hello_req_msg;
  struct message hello_ack_msg;
  
  msg_fill(&hello_req_msg, HELLO_REQ, 1, saddr, daddr, payload, sizeof(payload));
  
  net_send_msg(fd, &hello_req_msg);
  net_recv_msg(fd, &hello_ack_msg);
  //end_hello_req
  
  //ws = msg_ack.hdr.ws;
  ws = win_size;
  
  while(send_count + ws < count){
    for (uint32_t i = ws; i > 0; i--) {
      send_msg(fd, i, saddr, daddr, payload);
    }
    net_recv_msg(fd, &msg_ack);
    send_count += ws;
    //ws = msg_ack.hdr.ws;
  }
  for (uint32_t i = (count - send_count); i > 0; i--){
    send_msg(fd, i, saddr, daddr, payload);
  }
  net_recv_msg(fd, &msg_ack);
  
  //end_sendmessages
  
  if (close(fd) == -1) {
    printf("%d\n", errno);
  }
}

int main (int argc, char *argv[])
{
  int count = 1;
  int data_size = 1;
  uint32_t win_size = 1;
  int port_num = 8000;

  if(argc > 1){
    count = atoi(argv[1]);
  }else{
    printf("%s argument error count\n", __FILE__);
    return 0;
  }
  
  if(argc > 2){
    data_size = atoi(argv[2]);
  }else{
    printf("%s argument error datasize\n", __FILE__);
    return 0;
  }

  if(argc > 3){
    win_size = atoi(argv[3]);
  }else{
    printf("%s argument error winsize\n", __FILE__);
    return 0;
  }
  
  if(argc > 4){
    port_num = atoi(argv[4]);
    //strncpy(port_num, argv[4], sizeof(argv[4]));
  }else{
    printf("%s argument error portnum\n", __FILE__);
    return 0;
  }

  
  send_msgs("localhost", count, data_size, win_size, port_num);
  return 0;
}

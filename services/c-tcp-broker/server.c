#define _POSIX_SOURCE
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <netinet/tcp.h>

#include "../lib/message.h"
#include "../lib/network.h"

#define SERVER_PORT 9999
#define MAX_EVENTS 3000
#define BACKLOG 10
#define MAX_COUNT 100000
#define MAX_BUF_SIZE 5000
#define MAX_FD_SIZE 1024

#define CLOCK_HZ 2600000000.0

#define rdtsc_64(lower, upper) asm __volatile ("rdtsc" : "=a"(lower), "=d" (upper));

struct message msg_ary[MAX_COUNT];

volatile int data_num = 0;
volatile int recv_num = 0;

int msg_len[MAX_COUNT] = {0};
//pthread_mutex_t mutex;

unsigned long int gettsc()
{
  unsigned int tsc_l, tsc_u; //uint32_t

  rdtsc_64(tsc_l, tsc_u);
  return (unsigned long int)tsc_u<<32 | tsc_l;
}

static void die(const char* msg)
{
  perror(msg);
  exit(EXIT_FAILURE);
}

static int listener;

static int setup_socket(int port_no)
{
  int sock;
  struct sockaddr_in sin;

  if ((sock = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
    die("socket");
  }

  int on =1;
  int ret;
  ret = setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

  memset(&sin, 0, sizeof sin);
  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = htonl(INADDR_ANY);
  sin.sin_port = htons(port_no);

  if (bind(sock, (struct sockaddr *) &sin, sizeof sin) < 0) {
    close(sock);
    die("bind");
  }

  if (listen(sock, BACKLOG) < 0) {
    close(sock);
    die("listen");
  }

  return sock;
}

int store_msg(struct message *msg){
  uint64_t log_tsc;
  log_tsc = gettsc();
  msg_assign_time_stamp(msg, log_tsc, SERVER_RECV);
  msg_ary[data_num] = *msg;
  data_num++;

  return 0;
}

int shift_msg(struct message *msg){
  uint64_t log_tsc;
  int spin_count = 0;
  while(recv_num >= data_num){
    spin_count++;
  }  
  msg_len[recv_num] = data_num - recv_num;
  
  *msg = msg_ary[recv_num];
  recv_num++;
  msg->hdr.msg_type = RECV_MSG;
  log_tsc = gettsc();
  msg_assign_time_stamp(msg, log_tsc, SERVER_SEND);
  return 0;
}

void *loop (void* pArg){
  int *fdp = (int*) pArg;
  struct message msg;
  int fd = *fdp;
  int n = 0;
  
  while(1){
    if((n = net_recv_msg(fd, &msg)) != MSG_TOTAL_LEN) break;
    
    switch(msg.hdr.msg_type) {
    case SEND_MSG:
      store_msg(&msg);
      if(msg.hdr.ws == 1){
	net_send_ack(fd, &msg.payload, SEND_ACK, msg.hdr.ws, msg.hdr.saddr, msg.hdr.daddr);
      }
      break;
    case SEND_MSG_ACK:
      store_msg(&msg);
      net_send_ack(fd, &msg.payload, SEND_ACK, msg.hdr.ws, msg.hdr.saddr, msg.hdr.daddr);
      break;
    case RECV_N_REQ:{
      int ws = msg.hdr.ws;
      for(int i = 0; i < ws; i++){
	shift_msg(&msg);
	net_send_msg(fd, &msg);
      }
    }
      break;
    case RECV_ACK:
      for(int i = 0;i < recv_num;i++){
	printf("%d,%d\n",i,msg_len[i]);
      }
      break;
    default:break;
    }
  }
}

int main(int argc, char *argv[])
{
  int count = 1;
  int data_size = 1;
  int win_size = 1;
  int port_num = 8000;

  if(argc > 1){
    port_num = atoi(argv[1]);
  }else{
    printf("%s argument error portnum\n", __FILE__);
    return 0;
  }  
  
  pthread_t handle;
  listener = setup_socket(port_num);
  struct sockaddr_in client_addr;
  socklen_t client_addr_len = sizeof client_addr;
  
  for(int i = 0;i<2;i++){
    int fd = accept(listener,(struct sockaddr *) &client_addr, &client_addr_len);
    int on =1;
    int ret;
    ret = setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &on, sizeof(on));
    pthread_create(&handle, NULL, loop, &fd);
  }
  while (1){
    sleep(1);
  }
  return 0;
}

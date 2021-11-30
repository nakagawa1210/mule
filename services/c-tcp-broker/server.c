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

char array[MAX_COUNT][MAX_BUF_SIZE];
struct message msg_ary[MAX_COUNT];

int datanum = 0;
int recvnum = 0;

//pthread_mutex_t mutex;

unsigned long int gettsc()
{
  unsigned int tsc_l, tsc_u; //uint32_t

  rdtsc_64(tsc_l, tsc_u);
  return (unsigned long int)tsc_u<<32 | tsc_l;
}

void ackset(char *setbuf)
{
  while((datanum - recvnum) <= 0){
    //sleep(1);
  }
  memcpy(&setbuf[0], &array[recvnum][0], 4);
  memcpy(&setbuf[4], &array[recvnum][8], 4);
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

ssize_t writen(int fd,const void *vptr, size_t n)
{
  size_t nleft;
  ssize_t nwritten;
  const char *ptr;

  //現在の文字列の位置
  ptr = vptr;

  //残りの文字列の長さの初期化
  nleft = n;
  while (nleft > 0) {
    if ((nwritten = write(fd, ptr, nleft)) <= 0) {
      if (nwritten < 0 && errno == EINTR) {
	nwritten = 0;  // try again
      } else {
	return -1;
      }
    }
    nleft -= nwritten;
    ptr += nwritten;
  }
  return n;
}

ssize_t readn(int fd, void *buf, size_t count)
{
  int *ptr = buf;
  size_t nleft = count;
  ssize_t nread;

  while (nleft > 0) {
    if ((nread = read(fd, ptr, nleft)) < 0) {
      if (errno == EINTR)
        continue;
      else
        return -1;
    }
    if (nread == 0) {
      return count - nleft;
    }
    nleft -= nread;
    ptr += nread;
  }
  return count;
}

int send_msg(struct message *msg){
  unsigned long int log_tsc;
  log_tsc = gettsc();
  msg_assign_time_stamp(msg, log_tsc, SENDER_SEND);
  msg_ary[datanum] = *msg;
  datanum++;

  return 0;
}

int recv_msg(int count, int length, int winsize,int fd)
{
  char sendbuf[MAX_BUF_SIZE];
  unsigned long int log_tsc;
  char recvack[4];
  int loop_count = count / winsize;
  int len = 0;
  int spin_count = 0;
  
  for(int x = 0;x < loop_count;x++){
    for(int i = 0; i< winsize ;i++){
      spin_count = 0;
      do{
	len = datanum - recvnum;
	spin_count++;
      }while(len <= 0);

      memcpy(&array[recvnum][0],&len,sizeof(len));
      memcpy(&array[recvnum][4],&spin_count,sizeof(spin_count));
      log_tsc = gettsc();
      memcpy(&array[recvnum][length + 28],&log_tsc,sizeof(unsigned long int));

      writen(fd, &array[recvnum], length + 36);
      recvnum++;	     
    }
    readn(fd, recvack, sizeof(recvack));
  }
  return 1;
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
      send_msg(&msg);
      break;
    case SEND_MSG_ACK:
      send_msg(&msg);
      net_send_ack(fd, &msg.payload, SEND_ACK, msg.hdr.ws, msg.hdr.saddr, msg.hdr.daddr);
      break;
    case RECV_N_REQ:break;
    case RECV_ACK:break;
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

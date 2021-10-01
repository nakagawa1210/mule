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

#define SERVER_PORT 9999
#define MAX_EVENTS 3000
#define BACKLOG 10
#define MAX_COUNT 100000
#define MAX_BUF_SIZE 5000
#define MAX_FD_SIZE 1024

#define rdtsc_64(lower, upper) asm __volatile ("rdtsc" : "=a"(lower), "=d" (upper));

char array[MAX_COUNT][MAX_BUF_SIZE];
int ary_len[MAX_COUNT];

int datanum = 0;
int recvnum = 0;

//pthread_mutex_t mutex;

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
int send_msg(int count, int length, int winsize,int fd)
{ 
  char sendbuf[MAX_BUF_SIZE];
  unsigned int tsc_l, tsc_u;
  unsigned long int log_tsc;
  char sendack[4] = "ack";
  int loop_count = count / winsize;

  for(int x = 0;x < loop_count;x++){
    for(int i = 0; i< winsize ;i++){
      readn(fd, &sendbuf, length + 20);
      rdtsc_64(tsc_l, tsc_u);
      log_tsc = (unsigned long int)tsc_u<<32 | tsc_l;

      memcpy(&array[datanum][0], sendbuf,length + 20);
      memcpy(&array[datanum][length + 20] ,&log_tsc ,sizeof(log_tsc));
      datanum++;	     
    }
    writen(fd, sendack, sizeof(sendack));
  }
  return 1;
}

int recv_msg(int count, int length, int winsize,int fd)
{
  char sendbuf[MAX_BUF_SIZE];
  unsigned int tsc_l, tsc_u;
  unsigned long int log_tsc;
  char recvack[4];
  int loop_count = count / winsize;
  int len = 0;

  for(int x = 0;x < loop_count;x++){
    for(int i = 0; i< winsize ;i++){
      do{
	len = datanum - recvnum;
      }while(len <= 0);

      rdtsc_64(tsc_l, tsc_u);
      log_tsc = (unsigned long int)tsc_u<<32 | tsc_l;
      memcpy(&array[recvnum][length + 28],&log_tsc,sizeof(unsigned long int));

      writen(fd, &array[recvnum], length + 36);
      recvnum++;	     
    }
    readn(fd, recvack, sizeof(recvack));
  }
  return 1;
}

int analyze(char *data, int fd){
  //int length = *((int*)&data[0]);
  int count = 100000;
  int length = 0;
  int command = 0;
  int winsize = 0;
  
  memcpy(&length,&data[0],4);
  memcpy(&command,&data[4],4);
  memcpy(&winsize,&data[8],4);
  
  int res = 0;
  int num = 0;
  char ack[4] = "ack";
  char rack[8];

  switch (command){
  case 1 :
    writen(fd, ack, 4);
    res = send_msg(count, length * 1024, winsize, fd);
    break;
  case 2 :
    ackset(rack);
    writen(fd, rack, 8);
    res = recv_msg(count, length * 1024, winsize, fd);
    break;
  case 9 :
    res = 1;
    break;
  default:
    res = 0;
    break;
  }
  return res;
}

void *loop (void* pArg){
  int *fdp = (int*) pArg;
  char buf[16];
  int res;
  int fd = *fdp;
  while(1){
    readn(fd, buf, 16);
    res = analyze(buf, fd);
    if(res)break;
  }
}

int main(int argc, char *argv[])
{
  int count = 1;
  int data_size = 1;
  int win_size = 1;
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
  }else{
    printf("%s argument error portnum\n", __FILE__);
    return 0;
  }  
  
  pthread_t handle;
  listener = setup_socket(port_num);
  struct sockaddr_in client_addr;
  socklen_t client_addr_len = sizeof client_addr;
  
  int i=0;
  for(i;i<2;i++){
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

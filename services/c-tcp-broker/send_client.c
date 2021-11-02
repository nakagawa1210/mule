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
#define rdtsc_64(lower, upper) asm __volatile ("rdtsc" : "=a"(lower), "=d" (upper));

#define PORT_NO 9999
#define MAX_COUNT 100000
#define MEM_SIZE 5000

unsigned long int gettsc()
{
  unsigned int tsc_l, tsc_u; //uint32_t

  rdtsc_64(tsc_l, tsc_u);
  return (unsigned long int)tsc_u<<32 | tsc_l;
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

void send_msg (char *host, int count, int len,int winsize, int port_num){
  int loop_count = count / winsize;
  int msglen = len * 1024;
  char buf[msglen + 20];
  char iddata[16];
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
  
  int length = len;
  int command = 1;
  int endnum = 9;
  char enddata[16];
  char ack[4];
  char dummy_data = 'a';

  memcpy(&iddata[0],&length,sizeof(length));
  memcpy(&iddata[4],&command,sizeof(command));
  memcpy(&iddata[8],&winsize,sizeof(winsize));
  memcpy(&iddata[12],&count,sizeof(count));

  memcpy(&enddata[0],&len,sizeof(len));
  memcpy(&enddata[4],&endnum,sizeof(endnum));
  memcpy(&enddata[8],&winsize,sizeof(winsize));
  memcpy(&enddata[12],&count,sizeof(count));

  memcpy(&buf[0],&len,sizeof(len));
  memcpy(&buf[4],&command,sizeof(command));
  memcpy(&buf[8],&winsize,sizeof(winsize));
  for (int j = 12; j < msglen + 12; j++) {
    buf[j] = dummy_data;
  }   
  
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

  unsigned long int log_tsc;
  
  writen(fd, iddata, sizeof(iddata));
  readn(fd, ack, 4);

  for (int x = 0; x < loop_count; x++) {
    for (int i = 0; i < winsize; i++) {
      log_tsc = gettsc();
      memcpy(&buf[msglen + 12], &log_tsc, sizeof(log_tsc));
      
      writen(fd, buf, msglen + 20);
    } 
    readn(fd, ack, 4);
  }
  
  if (close(fd) == -1) {
    printf("%d\n", errno);
  }
}

int main (int argc, char *argv[])
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
  send_msg("localhost", count, data_size, win_size, port_num);
  return 0;
}

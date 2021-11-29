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

int send_n_request (int fd,
		    int n,
		    int saddr,
		    int daddr,
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
    send(fd, &smsg, MSG_TOTAL_LEN, 0);
  }
  return 0;
}

void send_msg (char *host, int count, int len,int win_size, int port_num){
  int loop_count = count / win_size;
  int rem_count = count % win_size;
  
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

  char payload[MSG_PAYLOAD_LEN] = "Hello";
  uint32_t saddr = 100;
  uint32_t daddr = 200;
  struct message tmp_msg;
  
  for (int i = 0; i < loop_count; i++) {
    send_n_request(fd, win_size, saddr, daddr, payload);
    readn(fd, &tmp_msg, MSG_TOTAL_LEN);
  }
  send_n_request(fd, rem_count, saddr, daddr, payload);  
  readn(fd, &tmp_msg, MSG_TOTAL_LEN);

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

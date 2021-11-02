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
#define rdtsc_64(lower, upper) asm __volatile ("rdtsc" : "=a"(lower), "=d" (upper));

#define CLOCK_HZ 2600000000.0
#define PORT_NO 9999
#define MAX_BUF_SIZE 5000
#define MAX_COUNT 200000

unsigned long int gettsc()
{
  unsigned int tsc_l, tsc_u; //uint32_t

  rdtsc_64(tsc_l, tsc_u);
  return (unsigned long int)tsc_u<<32 | tsc_l;
}

/* Read "n" bytes from a descriptor. */
ssize_t readn(int fd, void *buf, size_t count)
{
  char *ptr = buf;
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

void recv_msg(char *host, int count, int data_size, int win_size, int port_num)
{
  int loop_count = count / win_size;
  char buf[MAX_BUF_SIZE];
  uint64_t recv_time[MAX_COUNT][4];
  int len_log[MAX_COUNT];
  int spin_log[MAX_COUNT];
  int data_num = 0;
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  unsigned long int tsc; //uint64_t

  uint64_t end = 0;

  if (fd < 0) {
    perror("socket");
    return;
  }

  struct hostent *hp;
  if  ((hp = gethostbyname(host)) == NULL) {
    fprintf(stderr, "gethost error %s\n", host);
    close(fd);
    return;
  }

  struct sockaddr_in addr;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port_num);
  memcpy(&addr.sin_addr, hp->h_addr, hp->h_length);

  int command = 2;
  int endnum = 9;
  char iddata[16];
  char enddata[16];

  memcpy(&iddata[0],&data_size, 4);
  memcpy(&iddata[4],&command, 4);
  memcpy(&iddata[8],&win_size, 4);
  memcpy(&iddata[12],&count, 4);

  memcpy(&enddata[0],&data_size, 4);
  memcpy(&enddata[4],&endnum, 4);
  memcpy(&enddata[8],&win_size, 4);
  memcpy(&enddata[12],&count, 4);
  
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

  unsigned long int log_tsc;
  char setdata[8];
  int flag = 0;
  char ack[4];
  char endack[4];
  
  memcpy(&ack[0],&flag,sizeof(flag));
  flag = 1;
  memcpy(&endack[0],&flag,sizeof(flag));
  
  writen(fd, iddata, sizeof(iddata));
  readn(fd, setdata, 8);

  data_size = data_size * 1024;
  
  for(int x = 0;x < loop_count; x++){
    for (int i = 0;i < win_size; i++){
      readn(fd, buf, data_size + 36);
      log_tsc = gettsc();
      memcpy(&recv_time[data_num][0], &buf[data_size +12], sizeof(unsigned long int));
      memcpy(&recv_time[data_num][1], &buf[data_size +20], sizeof(unsigned long int));
      memcpy(&recv_time[data_num][2], &buf[data_size +28], sizeof(unsigned long int));
      memcpy(&recv_time[data_num][3], &log_tsc, sizeof(unsigned long int));
      memcpy(&len_log[data_num], &buf[0], sizeof(int));
      memcpy(&spin_log[data_num], &buf[4], sizeof(int));
      data_num++;
    }
    writen(fd, ack, sizeof(ack));
  }

  if (close(fd) == -1) {
    printf("%d\n", errno);
  }

  spin_log[0] = 0;
  printf("num,send,svr_in,svr_out,recv\n");
  for (int i = 0; i < count; i++) {
    printf("%d,%lf,%lf,%lf,%lf,%d,%d\n",i,
	   (recv_time[i][0]) / CLOCK_HZ,
	   (recv_time[i][1]) / CLOCK_HZ,
	   (recv_time[i][2]) / CLOCK_HZ,
	   (recv_time[i][3]) / CLOCK_HZ,
	   len_log[i],
	   spin_log[i]);
      }
  
  return;
}

int main(int argc, char *argv[])
{
  setvbuf(stdout, (char *)NULL, _IONBF, 0);
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
  
  if (argc < 2){
    printf("augument\n");
    return 0;
  }
  recv_msg("localhost", count, data_size, win_size, port_num);
  
  return 0;
}

#define _POSIX_SOURCE
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
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
#include "../lib/timer.h"

#define BACKLOG 10
#define MAX_COUNT 100000

struct message msg_ary[MAX_COUNT];

volatile int data_num = 0;
volatile int recv_num = 0;

int msg_len[MAX_COUNT] = {0};
pthread_mutex_t mutex;

static void die(const char *msg)
{
  perror(msg);
  exit(EXIT_FAILURE);
}

static int listener;

static int setup_socket(int port_no)
{
  int sock;
  struct sockaddr_in sin;

  if ((sock = socket(PF_INET, SOCK_STREAM, 0)) < 0)
  {
    die("socket");
  }

  int on = 1;
  int ret;
  ret = setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

  memset(&sin, 0, sizeof sin);
  sin.sin_family = AF_INET;
  sin.sin_addr.s_addr = htonl(INADDR_ANY);
  sin.sin_port = htons(port_no);

  if (bind(sock, (struct sockaddr *)&sin, sizeof sin) < 0)
  {
    close(sock);
    die("bind");
  }

  if (listen(sock, BACKLOG) < 0)
  {
    close(sock);
    die("listen");
  }

  return sock;
}

int store_msg(struct message *msg)
{
  uint64_t log_tsc;
  log_tsc = getclock();
  msg_assign_time_stamp(msg, log_tsc, SERVER_RECV);
  pthread_mutex_lock(&mutex);
  msg_ary[data_num] = *msg;
  pthread_mutex_unlock(&mutex);
  data_num++;

  return 0;
}

int shift_msg(struct message *msg, uint32_t ws)
{
  uint64_t log_tsc;
  int spin_count = 0;
  while (recv_num >= data_num)
  {
    spin_count++;
  }
  msg_len[recv_num] = data_num - recv_num;


  pthread_mutex_lock(&mutex);
  *msg = msg_ary[recv_num];
  pthread_mutex_unlock(&mutex);

  recv_num++;
  msg->hdr.msg_type = RECV_MSG;
  msg->hdr.fragments = ws;
  log_tsc = getclock();
  msg_assign_time_stamp(msg, log_tsc, SERVER_SEND);
  return 0;
}

void *loop(void *pArg)
{
  int *fdp = (int *)pArg;
  struct message msg;
  int fd = *fdp;
  int n = 0;

  while (1)
  {
    if ((n = net_recv_msg(fd, &msg)) != MSG_TOTAL_LEN)
    {
      break;
    }

    switch (msg.hdr.msg_type)
    {
    case SEND_MSG:
      store_msg(&msg);
      if (msg.hdr.fragments == 1)
      {
        uint32_t ws = msg.hdr.fragments;
        net_send_ack(fd, &msg.payload, SEND_ACK, ws, msg.hdr.saddr, msg.hdr.daddr);
      }
      break;
    case SEND_MSG_ACK:
      net_send_ack(fd, &msg.payload, SEND_ACK, msg.hdr.fragments, msg.hdr.saddr, msg.hdr.daddr);
      break;
    case RECV_N_REQ:
    {
      int ws = msg.hdr.fragments;
      for (int i = ws; i > 0; i--)
      {
        shift_msg(&msg, i);
        net_send_msg(fd, &msg);
      }
    }
    break;
    case RECV_ACK:
      // for (int i = 0; i < recv_num; i++)
      // {
      //   printf("%d,%d\n", i, msg_len[i]);
      // }
      break;
    case HELLO_REQ:
      net_send_ack(fd, &msg.payload, HELLO_ACK, msg.hdr.fragments, msg.hdr.saddr, msg.hdr.daddr);
      break;
    default:
      break;
    }
  }
}

int main(int argc, char *argv[])
{
  int port_num = 8000;

  if (argc > 1)
  {
    port_num = atoi(argv[1]);
  }
  else
  {
    printf("%s argument error portnum\n", __FILE__);
    return 0;
  }

  pthread_t handle;
  listener = setup_socket(port_num);
  struct sockaddr_in client_addr;
  socklen_t client_addr_len = sizeof client_addr;

  while (1)
  {
    int fd = accept(listener, (struct sockaddr *)&client_addr, &client_addr_len);
    int on = 1;
    int ret;
    ret = setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &on, sizeof(on));
    pthread_create(&handle, NULL, loop, &fd);
  }
  return 0;
}

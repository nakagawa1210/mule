#pragma once

#include <netdb.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#include "message.h"

int net_accept(int fd);
int net_close(int fd);
int net_connect(const char *host, const char *service);
int net_create_service(const char *host, const char *service);
int net_recv_ack(int fd, struct ack_message *msg, int expected_msg_type);
int net_recv_msg(int fd, struct message *msg);
int net_send_ack(int fd, void *payload, uint32_t msg_type, uint32_t ws, uint32_t saddr, uint32_t daddr);
int net_send_msg(int fd, struct message *msg);
int net_hello_req(int fd, uint32_t saddr, uint32_t daddr);

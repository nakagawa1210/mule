#include <string.h>
#include <stdio.h>

#include "message.h"

struct message *msg_fill_hdr(struct message *msg,
			     uint32_t msg_type,
			     uint32_t fragments,
			     uint32_t saddr,
			     uint32_t daddr) {

  msg->hdr.msg_type = msg_type;
  msg->hdr.fragments = fragments;
  msg->hdr.saddr = saddr;
  msg->hdr.daddr = daddr;
  return msg;
}

struct ack_message *msg_fill_ack_hdr(struct ack_message *msg,
			     uint32_t msg_type,
			     uint32_t ws,
			     uint32_t saddr,
			     uint32_t daddr) {

  msg->hdr.msg_type = msg_type;
  msg->hdr.ws = ws;
  msg->hdr.saddr = saddr;
  msg->hdr.daddr = daddr;
  return msg;
}
struct message *msg_fill(struct message *msg,
			 uint32_t msg_type,
			 uint32_t fragments,
                         uint32_t saddr,
			 uint32_t daddr,
                         void *payload,
			 int payload_len){

  msg_fill_hdr(msg, msg_type, fragments, saddr, daddr);

  if (payload) {
    memcpy(msg->payload, payload,
           payload_len > MSG_PAYLOAD_LEN ? MSG_PAYLOAD_LEN : payload_len);
  }

  return msg;
}

struct ack_message *ack_fill(struct ack_message *msg,
			 uint32_t msg_type,
			 uint32_t ws,
                         uint32_t saddr,
			 uint32_t daddr,
                         void *payload,
			 int payload_len){

  msg_fill_ack_hdr(msg, msg_type, ws, saddr, daddr);

  if (payload) {
    memcpy(msg->payload, payload,
           payload_len > MSG_PAYLOAD_LEN ? MSG_PAYLOAD_LEN : payload_len);
  }

  return msg;
}

struct message *msg_assign_time_stamp(struct message *msg,
				      uint64_t time_stamp,
				      int where) {
  switch(where) {
  case SENDER_SEND: msg->hdr.sender_send_time = time_stamp; return msg;
  case SERVER_RECV: msg->hdr.server_recv_time = time_stamp; return msg;
  case SERVER_SEND: msg->hdr.server_send_time = time_stamp; return msg;
  case RECVER_RECV: msg->hdr.recver_recv_time = time_stamp; return msg;
  default: return msg;
  }
}


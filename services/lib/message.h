#include <stdint.h>

#define MSG_PAYLOAD_LEN 1024
#define MSG_HEADER_LEN  (sizeof(struct message_header))
#define MSG_TOTAL_LEN   (MSG_HEADER_LEN + MSG_PAYLOAD_LEN)

struct message_header {
  uint32_t tot_len;  // total length including payload
  uint32_t msg_type; // RECV_N_REQUEST, SEND_N_REQUEST
  uint32_t ws;  //window size
  uint32_t saddr; //source address
  uint32_t daddr; //destination address
  uint64_t sender_send_time;
  uint64_t server_recv_time;
  uint64_t server_send_time;
  uint64_t recver_recv_time;
};


struct message {
  struct message_header hdr;
  char payload[MSG_PAYLOAD_LEN];
};
   
struct ack_header {
  uint32_t msg_type;
  uint32_t ack_ok;
};

struct message_ack {
  struct message_header hdr;
  char payload[MSG_PAYLOAD_LEN];
};

#define SEND_N_REQ  1 // sender -> server (+payload)
#define SEND_ACK  2 // server -> sender

#define RECV_N_REQ  3 // receiver -> server
#define RECV_MSG  4 // server -> receiver (+payload)

#define SENDER_SEND 1
#define SERVER_RECV 2
#define SERVER_SEND 3
#define RECVER_RECV 4

struct message *msg_fill_hdr(struct message *msg,
			     uint32_t msg_type,
			     uint32_t ws,
			     uint32_t saddr,
			     uint32_t daddr);

struct message *msg_fill(struct message *msg,
                         uint32_t msg_type,
                         uint32_t saddr,
                         uint32_t daddr,
                         uint32_t id,
                         void *payload,
                         int payload_len);

struct message *msg_assign_time_stamp(struct message *msg,
				      uint64_t time_stamp,
				      int where);

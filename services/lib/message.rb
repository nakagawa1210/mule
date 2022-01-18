require "socket"

MSG_PAYLOAD_LEN = 1024
MSG_HEADER_LEN = 4 + 4 + 4 + 4 + 4 + 8 + 8 + 8 + 8 
MSG_TOTAL_LEN = MSG_PAYLOAD_LEN + MSG_HEADER_LEN


Message = Struct.new(:tot_len,
                     :msg_type, 
                     :fragments,
                     :saddr,
                     :daddr,
                     :sender_send_time,
                     :server_recv_time,
                     :server_send_time,
                     :recver_recv_time,
                     :payload)

Ack_Message = Struct.new(:tot_len,
                     :msg_type, 
                     :ws,
                     :saddr,
                     :daddr,
                     :sender_send_time,
                     :server_recv_time,
                     :server_send_time,
                     :recver_recv_time,
                     :payload)

SEND_MSG = 1      # sender -> server (+payload)
SEND_MSG_ACK = 2  # sender -> server (+payload) then sender wait ack 
SEND_ACK = 3      # server -> sender

RECV_N_REQ = 3    # receiver -> server
RECV_MSG = 4      # server -> receiver (+payload)
RECV_ACK = 6      # receiver -> server

HELLO_REQ = 7     # client -> server
HELLO_ACK = 8     # server -> client


SENDER_SEND = 1
SERVER_RECV = 2
SERVER_SEND = 3
RECVER_RECV = 4

def msg_fill_hdr(msg, msg_type, fragments, saddr, daddr)  
  msg.tot_len = MSG_TOTAL_LEN
  msg.msg_type = msg_type
  msg.fragments = fragments
  msg.saddr = saddr
  msg.daddr = daddr

  msg.sender_send_time ||= 0.0
  msg.server_recv_time ||= 0.0
  msg.server_send_time ||= 0.0
  msg.recver_recv_time ||= 0.0

  return msg
end

def msg_fill_ack_hdr(msg, msg_type, ws, saddr, daddr)  
  msg.tot_len = MSG_TOTAL_LEN
  msg.msg_type = msg_type
  msg.ws = ws
  msg.saddr = saddr
  msg.daddr = daddr

  msg.sender_send_time ||= 0.0
  msg.server_recv_time ||= 0.0
  msg.server_send_time ||= 0.0
  msg.recver_recv_time ||= 0.0

  return msg
end

def msg_fill(msg, msg_type, fragments, saddr, daddr, payload)
  msg_fill_hdr(msg, msg_type, fragments, saddr, daddr)
  
  msg.payload = (payload.length < MSG_PAYLOAD_LEN) ? payload : payload.slice(0, MSG_PAYLOAD_LEN)
  
  return msg
end

def ack_fill(msg, msg_type, ws, saddr, daddr, payload)
  msg_fill_ack_hdr(msg, msg_type, ws, saddr, daddr)
  
  msg.payload = payload.length < MSG_PAYLOAD_LEN ? payload : payload.slice(0, MSG_PAYLOAD_LEN)
  
  return msg
end

def msg_assign_time_stamp(msg, time_stamp, where)
  case where
  when SENDER_SEND then
    msg.sender_send_time = time_stamp
  when SERVER_RECV then
    msg.server_recv_time = time_stamp
  when SERVER_SEND then
    msg.server_send_time = time_stamp
  when RECVER_RECV then
    msg.recver_recv_time = time_stamp
  end
end

def msg_pack(msg)
  data = [msg.tot_len,
          msg.msg_type, 
          msg.fragments,
          msg.saddr,
          msg.daddr,
          msg.sender_send_time,
          msg.server_recv_time,
          msg.server_send_time,
          msg.recver_recv_time,
          msg.payload].pack("I!5G4a1024")
end

def ack_pack(msg)
  data = [msg.tot_len,
          msg.msg_type, 
          msg.ws,
          msg.saddr,
          msg.daddr,
          msg.sender_send_time,
          msg.server_recv_time,
          msg.server_send_time,
          msg.recver_recv_time,
          msg.payload].pack("I!5G4a1024")
end

def msg_unpack(data)
  msg = Message.new
  msg = data.unpack("I!5G4a1024")
end

def ack_unpack(data)
  msg = Ack_Message.new
  msg = data.unpack("I!5G4a1024")
end

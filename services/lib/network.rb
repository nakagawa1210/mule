def net_send_msg(s, msg)
  data = msg_pack(msg)
  n = s.send(data, 0)
end

def net_send_ack(s, payload, msg_type, ws, saddr, daddr)
  msg = Ack_Message.new
  ack_fill(msg, msg_type, ws, saddr, daddr, payload)
  
  data = ack_pack(msg)
  n = s.send(data, 0)
end

def time_set(msg, data)
  msg.sender_send_time = data[5]
  msg.server_recv_time = data[6]
  msg.server_send_time = data[7]
  msg.recver_recv_time = data[8]
end

def net_recv_msg(s, msg)
  data = s.read(MSG_TOTAL_LEN)
  n = data&.size
  return -1 if n == nil || n != MSG_TOTAL_LEN
  
  data_ary = msg_unpack(data)
  msg_fill(msg, data_ary[1], data_ary[2], data_ary[3], data_ary[4], data_ary[9])
  time_set(msg, data_ary)

  return n
end

def net_recv_ack(s, msg, msg_type)
  data = s.read(MSG_TOTAL_LEN)
  n = data&.size
  return -1 if n == nil || n != MSG_TOTAL_LEN
  
  data_ary = ack_unpack(data)
  ack_fill(msg, data_ary[1], data_ary[2], data_ary[3], data_ary[4], data_ary[9])

  return -1 if msg.msg_type != msg_type
  
  return n
end

def net_hello_req(s, saddr, daddr)
  payload = "Hello"
  hello_req_msg = Message.new
  hello_ack_msg = Ack_Message.new
  
  msg_fill(hello_req_msg, HELLO_REQ, 1, saddr, daddr, payload)
  
  net_send_msg(s, hello_req_msg)
  n = net_recv_ack(s, hello_ack_msg, HELLO_ACK)

  return n
end

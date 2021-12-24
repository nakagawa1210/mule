def net_send_msg(s, msg)
  data = msg_pack(msg)
  n = s.send(data)
end

def net_recv_msg(s)
  msg = Message.new
  data = s.read(MSG_TOTAL_LEN)
  msg = msg_unpack(data)
end

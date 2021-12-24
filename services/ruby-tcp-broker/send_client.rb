require "../lib/message.rb"
require "../lib/network.rb"
require "socket"

def send_msg(s, ws, saddr, daddr, payload)
  msg = msg_fill(SEND_MSG, ws, saddr, daddr, payload)
  time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  msg = msg_assign_time_stamp(msg, time, SENDER_SEND)
  net_send_msg(s, msg)
end
  
def send_msgs(host, count, data_size, win_size, port_num)
  s = TCPSocket.open(host, port_num)
  s.setsockopt(Socket::IPPROTO_TCP,Socket::TCP_NODELAY,true)

  #start_send_messages
  payload = "Hello"
  saddr = 100
  daddr = 200
  ws = 1;

  msg_ack = Message.new
  send_count = 0; 

  #hello_req
  hello_req_msg = msg_fill(HELLO_REQ, ws, saddr, daddr, payload)
  hello_ack_msg = Message.new
  
  net_send_msg(s, hello_req_msg)
  hello_ack_msg = net_recv_msg(s)
  #end_hello_req

  #ws = hello_ack_msg.ws
  ws = win_size

  while (send_count + ws) < count do
    for i in ws..1 do
      send_msg(s, i, saddr, daddr, payload)
    end
    msg_ack = net_recv_msg(s)
    send_count += ws
  end

  for i in (count - send_count)..1 do
    send_msg(s, i, saddr, daddr, payload)
  end
  msg_ack = net_recv_msg(s)
#end_send_msgs

  s.close
end
  
def main()
  if ARGV.size > 0
    count = ARGV[0].to_i
  else
    file = File.basename(__FILE__)
    STDERR.printf("%s argument error count\n", file)
    exit
  end
  
  if ARGV.size > 1
    data_size = ARGV[1].to_i
  else
    file = File.basename(__FILE__)
    STDERR.printf("%s argument error data_size\n", file)
    exit
  end
  
  if ARGV.size > 2
    window_size = ARGV[2].to_i
  else
    file = File.basename(__FILE__)
    STDERR.printf("%s argument error window_size\n", file)
    exit
  end
  
  if ARGV.size > 3
    port_num = ARGV[3].to_i
  else
    file = File.basename(__FILE__)
    STDERR.printf("%s argument error port_num\n", file)
    exit
  end
  
  if (count < window_size)
    puts"count < window_size"
    exit
  end

  send_msgs("localhost", count, data_size, win_size, port_num)
end

main


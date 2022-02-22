require "../lib/message.rb"
require "../lib/network.rb"
require "../lib/timer.rb"
require "socket"

WS_1 = 1
$time_count = 0

def recv_msg(s)
  msg = Ack_Message.new
  net_recv_ack(s, msg, SEND_ACK)
  ws = msg.ws
end

def send_msg(s, fragments, saddr, daddr, payload)
  msg = Message.new
  msg = msg_fill(msg, SEND_MSG, fragments, saddr, daddr, payload)
  time = getclock()
  msg_assign_time_stamp(msg, time, SENDER_SEND)
  net_send_msg(s, msg)
end

def send_msgs(host, count, data_size, win_size, port_num)
  s = TCPSocket.open(host, port_num)
  s.setsockopt(Socket::IPPROTO_TCP,Socket::TCP_NODELAY,true)

  #start_send_messages
  payload = "Hello"
  saddr = 100
  daddr = 200
  next_ws = WS_1

  send_count = 0

  net_hello_req(s, saddr, daddr)

  ws = WS_1

  while (send_count + ws) < count do
    ws.downto(1) do |i|
      send_msg(s, i, saddr, daddr, payload)
    end
    next_ws = recv_msg(s)
    send_count += ws
    #ws = next_ws
    ws = win_size
  end

  left_count = count - send_count
  left_count.downto(1) do |i|
    send_msg(s, i, saddr, daddr, payload)
  end
  recv_msg(s)
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
    win_size = ARGV[2].to_i
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

  if (count < win_size)
    puts"count < window_size"
    exit
  end

  send_msgs("localhost", count, data_size, win_size, port_num)
end

main


require "../lib/message.rb"
require "../lib/network.rb"
require "socket"
MAX_COUNT = 100000

$msg_ary = Array.new(MAX_COUNT)
$data_num = 0
$recv_num = 0

$msg_len = Array.new(MAX_COUNT)

def store_msg(msg)
  time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  msg_assign_time_stamp(msg, time, SERVER_RECV) 

  $msg_ary[$data_num] = msg
  $data_num += 1
end

def shift_msg(msg, fragments)
  spin_count = 0
  while $recv_num >= $data_num do
    spin_count += 1
  end

  $msg_len[$recv_num] = spin_count
  
  msg = $msg_ary[$recv_num]
  $recv_num += 1
  msg.msg_type = RECV_MSG
  msg.fragments = fragments
  time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  msg_assign_time_stamp(msg, time, SERVER_SEND)
  return msg
end

def treat_client(gs)
  s = gs
  msg = Message.new
  
  loop do
    n = net_recv_msg(s, msg)
    break if n != MSG_TOTAL_LEN
    case msg.msg_type
    when SEND_MSG then
      store_msg(msg)
      msg.fragments
      if msg.fragments == 1
        ws = msg.fragments
        net_send_ack(s, msg.payload, SEND_ACK, ws, msg.saddr, msg.daddr)
      end
    when SEND_MSG_ACK then
    when RECV_N_REQ then
      ws = msg.fragments
      ws.downto(1) do |i|
        p i
        smsg = shift_msg(msg, i)
        net_send_msg(s, smsg)
      end
    when RECV_ACK then
      $recv_num.times do |num|
        #puts "#{num},#{$msg_len[num]}"
      end
      p $data_num
      p $recv_num
    when HELLO_REQ then
      net_send_ack(s, msg.payload, HELLO_ACK, msg.fragments, msg.saddr, msg.daddr)
    else false
    end
  end
  p "end treat"
end

def main ()
  if ARGV.size > 0
    port_num = ARGV[0].to_i
  else
    file = File.basename(__FILE__)
    STDERR.printf("%s argument error port_num\n", file)
    exit
  end
  
  gs = TCPServer.open(port_num)
  gs.setsockopt(Socket::IPPROTO_TCP,Socket::TCP_NODELAY,true)
  addr = gs.addr
  addr.shift
  
  res = 0
  
  while true
    Thread.start(gs.accept) do |s|
      treat_client(s)
      s.close
    end
  end
end

main


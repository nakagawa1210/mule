require "../lib/message.rb"
require "../lib/network.rb"
require "socket"
MAX_COUNT = 100000
ERROR = -1

$msg_ary = Array.new(MAX_COUNT)
$data_num = 0
$recv_num = 0

$msg_len = Array.new(MAX_COUNT)

$send_time_count = 0
$recv_time_count = 0
$time_ary = Array.new(MAX_COUNT + 1){Array.new(3, 0.0)}

def store_msg(msg)
  time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  msg_assign_time_stamp(msg, time, SERVER_RECV)
  $msg_ary[$data_num] = msg
  $data_num += 1
  $time_ary[$send_time_count][0] = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  $send_time_count += 1
end

def shift_msg(fragments)
  spin_count = 0
  while $recv_num >= $data_num do
    spin_count += 1
  end
  $msg_len[$recv_num] = $recv_num - $data_num

  $time_ary[$recv_time_count][2] = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  $recv_time_count +=1

  msg = $msg_ary[$recv_num]
  $recv_num += 1

  msg.msg_type = RECV_MSG
  msg.fragments = fragments
  time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  msg_assign_time_stamp(msg, time, SERVER_SEND)
  return msg
end

def treat_client(s)
  while 1 do
    msg = net_recv_msg(s, msg)
    break if msg == ERROR
    #puts msg.msg_type
    case msg.msg_type
    when SEND_MSG then
      store_msg(msg)
      if msg.fragments == 1
        $time_ary[$send_time_count][1] = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        net_send_ack(s, msg.payload, SEND_ACK, msg.fragments, msg.saddr, msg.daddr)
      end
    when SEND_MSG_ACK then
    when RECV_N_REQ then
      ws = msg.fragments
      ws.downto(1) do |i|
        smsg = shift_msg(i)
        net_send_msg(s, smsg)
      end
    when RECV_ACK then
      $send_time_count.times do |num|
        puts "#{num},#{$time_ary[num][0]},#{$time_ary[num][1]},#{$time_ary[num][2]}"
      end
    when HELLO_REQ then
      net_send_ack(s, msg.payload, HELLO_ACK, msg.fragments, msg.saddr, msg.daddr)
    else false
    end
  end
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


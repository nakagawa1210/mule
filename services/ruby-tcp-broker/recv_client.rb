require_relative "../lib/message.rb"
require_relative "../lib/network.rb"
require_relative "../lib/timer.rb"
require 'socket'

MAX_COUNT = 100000
WS_1 = 1

$msg_ary = Array.new(MAX_COUNT)
$data_num = 0

def send_ack(s, msg_type, ws, saddr, daddr)
  payload = "Hello"
  n = net_send_ack(s, payload, msg_type, ws, saddr, daddr)
end

def recv_msg(s, saddr, daddr)
  msg = Message.new
  msg = net_recv_msg(s, msg)
  time = getclock()
  msg_assign_time_stamp(msg, time, RECVER_RECV)
  $msg_ary[$data_num] = msg
  $data_num += 1

  return msg.fragments
end

def recv_n_msg(s, n, saddr, daddr)
  n.times do
    p recv_msg(s, saddr, daddr)
  end
end

def print_timestamp()
  puts "num,send,svr_in,svr_out,recv"
  $data_num.times do |num|
    puts "#{num},#{$msg_ary[num].sender_send_time.to_f / (1000 * 1000 * 1000)},#{$msg_ary[num].server_recv_time.to_f / (1000 * 1000 * 1000)},#{$msg_ary[num].server_send_time.to_f / (1000 * 1000 * 1000)},#{$msg_ary[num].recver_recv_time.to_f / (1000 * 1000 * 1000)}"
  end
end

def recv_msgs(count, data_size, win_size, port_num)
  s = TCPSocket.open("localhost", port_num)
  s.setsockopt(Socket::IPPROTO_TCP,Socket::TCP_NODELAY,true)

  payload = "Hello"
  saddr = 200
  daddr = 100

  recv_count = 0

  net_hello_req(s, saddr, daddr)

  while(recv_count + win_size) < count do
    send_ack(s, RECV_N_REQ, win_size, saddr, daddr)
    loop do
      fragments = recv_msg(s, saddr, daddr)
      if(fragments == 1)
        recv_count += win_size
        break
      end
    end
  end
  left_count = count - recv_count
  send_ack(s, RECV_N_REQ, left_count, saddr, daddr)
  left_count.times do
    recv_msg(s, saddr, daddr)
  end
  send_ack(s, RECV_ACK, WS_1, saddr, daddr)

  s.close
end

def main
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
    STDERR.printf("%s argument error datasize\n", file)
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

  recv_msgs(count, data_size, win_size, port_num)
  print_timestamp()
end

main


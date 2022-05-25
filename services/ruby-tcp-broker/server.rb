require_relative "../lib/message.rb"
require_relative "../lib/network.rb"
require_relative "../lib/timer.rb"
require "socket"
MAX_COUNT = 100000
ERROR = -1

$msg_ary = Array.new(MAX_COUNT)
$data_num = 0
$recv_num = 0

$msg_ary_mu = Mutex.new()
$recv_lock_cnt = 0
$send_lock_cnt = 0
$recv_lock_time = Array.new(MAX_COUNT)
$send_lock_time = Array.new(MAX_COUNT)

$msg_len = Array.new(MAX_COUNT)

$time_count = 0

def store_msg(msg)
  time = getclock()
  msg_assign_time_stamp(msg, time, SERVER_RECV)

  if $msg_ary_mu.try_lock == false then
    $send_lock_time[$send_lock_cnt] = [getclock(), 0]
    $msg_ary_mu.lock
    $send_lock_time[$send_lock_cnt][1] = getclock()
    $send_lock_cnt += 1
  end
  $msg_ary[$data_num] = msg
  $data_num += 1
  $msg_ary_mu.unlock
end

def shift_msg(fragments)
  spin_count = 0
  while $recv_num >= $data_num do
    spin_count += 1
    sleep 0.1
  end
  $msg_len[$recv_num] = spin_count

  if $msg_ary_mu.try_lock == false then
#    $recv_lock_time[$recv_lock_cnt] = [getclock(), 0]
    $msg_ary_mu.lock
#    $recv_lock_time[$recv_lock_cnt][1] = getclock()
    $recv_lock_cnt += 1
  end
  msg = $msg_ary[$recv_num]
  $recv_num += 1
  $msg_ary_mu.unlock

  msg.msg_type = RECV_MSG
  msg.fragments = fragments
  time = getclock()
  msg_assign_time_stamp(msg, time, SERVER_SEND)
  return msg
end

def treat_client(s)
  loop do
    msg = net_recv_msg(s, msg)
    break if msg == ERROR
    case msg.msg_type
    when SEND_MSG then
      store_msg(msg)
      if msg.fragments == 1
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
      #send_lock_sum = 0
      #recv_lock_sum = 0
      #$send_lock_cnt.times do |i|
      #  send_lock_sum += $send_lock_time[i][1] - $send_lock_time[i][0]
      #end
      #$recv_lock_cnt.times do |i|
      #  recv_lock_sum += $recv_lock_time[i][1] - $recv_lock_time[i][0]
      #end
      #puts "send_lock,#{$send_lock_cnt},recv_lock,#{$recv_lock_cnt}"
      #puts "send_lock_time,#{send_lock_sum},recv_lock_time,#{recv_lock_sum}"
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


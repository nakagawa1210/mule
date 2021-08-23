require "socket"

class MsgServer < TCPServer
  def initialize()
    $array = []
    @ID = []
    $array_mu = Mutex.new()
    $recv_lock = 0
    $send_lock = 0
    $recv_lock_time = []
    $send_lock_time = []
  end

  def analyze(data, s, count, data_size, window_size)
    data = data.chomp
    
    buf = data.partition("/")
    command = buf[0].to_i
    winsize = buf[2].to_i
    
    case command
    when 1 then
      s.write("\n")
      send_msg(count, window_size, s)
    when 2 then
      recv_msg(count, window_size, s)
    when 9 then true
    when 5 then 5
    else false
    end
  end
  
  def make_responsedata(command,length,dest,msgid,rescode)
    data = command.to_s << '/' << length.to_s << '/' <<  dest.to_s << '/' << msgid.to_s << '/' << rescode.to_s << "\n"
    return data 
  end
  
  def check_id()
    puts "send_lock_start,send_lock_end,recv_lock_start,recv_lock_end"
    $recv_lock_time.length.times do |n|
      puts "#{$send_lock_time[n][0]},#{$send_lock_time[n][1]},#{$recv_lock_time[n][0]},#{$recv_lock_time[n][1]}"
      return true
    end
  end
  
  def recv_msg(count, win_size, s)
    msg_count = 0
    loop do
      win_size.times do
        spin_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      
        while $array.length == 0
          sleep(0.0001)
        end
      
        lock_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        $recv_lock += 1 if $array_mu.locked?
        $array_mu.lock
        lock_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        begin      
          recvdata = $array.shift
          shift_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        ensure
          $array_mu.unlock
        end
        $recv_lock_time.push [spin_start, lock_start, lock_end, shift_end]
        
        time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        data = recvdata << ',' << time.to_s << "\n"
        s.write(data)
        msg_count += 1
      end
      break if msg_count == count
      s.gets
    end
    return false
  end 
  
  def send_msg(count, winsize, s)
    msg_count = 0
    loop do
      winsize.times do
        s.gets
        time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        msg_count += 1
        senddata = $_.chomp
        senddata << ',' << time.to_s
        lock_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        
        $send_lock += 1 if $array_mu.locked?
        $array_mu.lock
        lock_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        begin
          $array.push senddata
          push_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        ensure
          $array_mu.unlock
        end
      
        $send_lock_time.push [lock_start, lock_end, push_end] 
      end
      s.write(make_responsedata(1,2,3,4,5))
      break if msg_count == count
    end
    return false
  end
end 


def main ()
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
    window_size = ARGV[2].to_i
  else
    file = File.basename(__FILE__)
    STDERR.printf("%s argument error window_size\n", file)
    exit
  end
  
  gs = TCPServer.open(50052)
  gs.setsockopt(Socket::IPPROTO_TCP,Socket::TCP_NODELAY,true)
  addr = gs.addr
  addr.shift
  
  stub = MsgServer.new()

  res = 0
  
  while true
    Thread.start(gs.accept) do |s|
      loop do
        s.gets
        res = stub.analyze($_,s, count, data_size, window_size)
        break if res
      end
      s.close
      if res == 5
        puts "s_lock_start,s_lock_end,shift_end,spin_start,r_lock_start,r_lock_end,push_end,send_lock = #{$send_lock} recv_lock = #{$recv_lock}"
        $recv_lock_time.length.times do |n|
          puts "#{$send_lock_time[n][0]},#{$send_lock_time[n][1]},#{$send_lock_time[n][2]},#{$recv_lock_time[n][0]},#{$recv_lock_time[n][1]},#{$recv_lock_time[n][2]},#{$recv_lock_time[n][3]}"
        end
      end
    end
  end
end

main


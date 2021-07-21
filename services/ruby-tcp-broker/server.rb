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

  def analyze(data,s)
    data = data.chomp
    
    buf = data.partition("/")
    command = buf[0].to_i
    winsize = buf[2].to_i
    
    case command
    when 1 then
      s.write("\n")
      send_msg(winsize,s)
    when 2 then recv_msg(s)
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
  
  def recv_msg(s)
    loop do
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
      break if $array.length == 0
    end
    s.write("8\n")
    return false
  end 
  
  def send_msg(winsize,s)
    winsize.times do
      s.gets
      time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
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
    return false
  end
end 


def main ()
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
        res = stub.analyze($_,s)
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


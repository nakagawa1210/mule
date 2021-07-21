require 'socket'

def main
  count = ARGV.size > 0 ?  ARGV[0].to_i : 10
  port = 50052
  s = TCPSocket.open("localhost", port)
  s.setsockopt(Socket::IPPROTO_TCP,Socket::TCP_NODELAY,true)
  
  length = 1
  command = 2
  dest = 3
  msgid = 4

  iddata = command.to_s << '/' << length.to_s << '/' << dest.to_s << '/' << msgid.to_s 

  recvdata = []

  s.write(iddata + "\n")
  
  loop do
    s.gets
    
    if $_[0] == '8'
      s.write(iddata + "\n")
      s.gets
    end
    time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    data = $_.chomp
    data << ',' << time.to_s

    recvdata.push data

    break if recvdata.length == count
  end
  s.gets
  s.write("5\n")
  s.close
  
  puts "num,send,svr_in,svr_out,recv" 
  recvdata.each do |data|
    buf = data.partition("/")
    command = buf[0]
    data = buf[2]
    buf = data.partition("/")
    length = buf[0]
    data = buf[2]
    buf = data.partition("/")
    dest = buf[0]
    data = buf[2]
    buf = data.partition(",")
    message = buf[0]
    data = buf[2]
    
    buf = data.rpartition(",")
    t_4 = buf[2]
    data = buf[0]
    buf = data.rpartition(",")
    t_3 = buf[2]
    data = buf[0]
    buf = data.rpartition(",")
    t_2 = buf[2]
    data = buf[0]
    buf = data.rpartition(",")    
    t_1 = buf[2]
    data = buf[0]
    puts "#{dest},#{t_1},#{t_2},#{t_3},#{t_4}"
  end
end

main


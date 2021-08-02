require "socket"

class MakeSendArray
  def initialize(count, data_size)
    @senddata = []
    (0 ... count).each do |num|
      message = makepaket(data_size)

      length = message.length
      command = 1
      dest = num
      
      @senddata.push make_senddata(command,
                                   length,
                                   dest,
                                   message)
    end
  end

  def makepaket(size)
    count = size * 1024
    data = "#{size}kBdata".ljust(count, "*")
    return data
  end
  
  def each
    return enum_for(:each) unless block_given?
    @senddata.each do |data|
      time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      send = data + ',' + time.to_s + "\n"
      yield send
    end
  end

  def make_senddata(command,length,dest,message)
    data = command.to_s << '/' << length.to_s << '/' <<  dest.to_s << '/' << message
    return data 
  end
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
  
  if (count < window_size)
    puts"count < window_size"
    exit
  end

  port = 50052
  s = TCPSocket.open("localhost", port)
  s.setsockopt(Socket::IPPROTO_TCP,Socket::TCP_NODELAY,true)

  loop_count = count / window_size

  senddata = MakeSendArray.new(window_size,data_size)

  windata = "1/" + window_size.to_s + "\n"

  s.write(windata)
  s.gets

  loop_count.times do
    senddata.each{|data| s.write(data)}
    s.gets
  end
  
  s.write("9\n")
  s.close
end

main


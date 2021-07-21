this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(File.dirname(this_dir), 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_broker_services_pb'

class MakeSendArray
  def initialize(count, datasize)
    @senddata = []
    (0 ... count).each do |num|
      message = makepaket(datasize)

      length = message.length
      command = 1
      dest = num
      
      @senddata.push Msg::SendData.new(length: length,
                                       command: command,
                                       dest: dest,
                                       message: message,
                                       T_1: 1,
                                       T_2: 2,
                                       T_3: 3,
                                       T_4: 4)
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
      time =  Process.clock_gettime(Process::CLOCK_MONOTONIC)
      data.T_1 = time
      yield  data
    end
  end
end


def main()
  count = ARGV.size > 0 ?  ARGV[0].to_i : 100
  datasize = ARGV.size > 1 ?  ARGV[1].to_i : 1
  window_size = ARGV.size > 2 ?  ARGV[2].to_i : 1
  hostname = 'localhost:50051'
  stub = Msg::Frame::Stub.new(hostname, :this_channel_is_insecure)
  
  if (count < window_size)
    puts"count < window_size"
    exit
  end
  
  loop_count = count / window_size

  senddata = MakeSendArray.new(window_size,datasize)

  loop_count.times do |n|
    response = stub.send_msg(senddata.each)
  end
end

main

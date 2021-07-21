this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(File.dirname(this_dir), 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_broker_services_pb'

def main
  count = ARGV.size > 0 ?  ARGV[0].to_i : 10
  hostname = ARGV.size > 1 ?  ARGV[1] : 'localhost:50051'
  stub = Msg::Frame::Stub.new(hostname, :this_channel_is_insecure)

  @recvdata = []
  
  (0 ... count).each do |num|
    message = ""
    
    length = message.length
    command = 1
    dest = num
    msgid = 2
      
    @recvdata.push Msg::RecvData.new(length: length,
                                     command: command,
                                     dest: dest,
                                     msgid: msgid,
                                     message: message,
                                     T_1: 1,
                                     T_2: 2,
                                     T_3: 3,
                                     T_4: 4)
  end
  
  length = 1
  command = 2
  dest = 3
  msgid = 4

  iddata = Msg::IdData.new(length: length,
                           command: command,
                           dest: dest,
                           msgid: msgid)
  @n = 0
  
  loop do
    recv = stub.recv_msg(iddata)
    recv.each_entry do |data|
      time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      data.T_4 = time
      
      @recvdata[@n] = data
      @n += 1
    end
    break if @n == count
  end
  
  puts "num,send,svr_in,svr_out,recv"
  @recvdata.each do |s|
    puts "#{s.dest},#{s.T_1},#{s.T_2},#{s.T_3},#{s.T_4}"
  end
  time = stub.check_id(iddata)
end

main


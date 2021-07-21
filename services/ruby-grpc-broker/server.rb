this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(File.dirname(this_dir), 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_broker_services_pb'

class Recv
  def initialize()
    
  end

  def each
    return enum_for(:each) unless block_given?
    loop do
      while $array.length == 0
        sleep(0.001)
      end

      lock_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      $recv_lock += 1 if $array_mu.locked?
      #$array_mu.lock
      lock_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      #begin
        recvdata = $array.shift
      #ensure
      #  $array_mu.unlock
      #end
      $recv_lock_time.push [lock_start, lock_end]

      time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      #      puts "#{recvdata.dest},#{$array.length}"
      
      yield Msg::RecvData.new(length: recvdata.length,
                              command: recvdata.command,
                              dest: recvdata.dest,
                              msgid: 1,
                              message: recvdata.message,
                              T_1: recvdata.T_1,
                              T_2: recvdata.T_2,
                              T_3: time,
                              T_4: recvdata.T_4)
        
      break if $array.length == 0
    end
  end
end



class MsgServer < Msg::Frame::Service
  def initialize()
    $array = []
    @ID = []
    $recv_lock = 0
    $send_lock = 0
    $recv_lock_time = []
    $send_lock_time = []
  end
  
  def check_id(iddata, _unused_call)
    @ID.push iddata
    puts "s_lock_start,s_lock_end,r_lock_start,r_lock_end send_lock = #{$send_lock} recv_lock = #{$recv_lock}"
    $recv_lock_time.length.times do |n|
      puts "#{$send_lock_time[n][0]},#{$send_lock_time[n][1]},#{$recv_lock_time[n][0]},#{$recv_lock_time[n][1]}"
    end

    Msg::Response.new(length: 1,
                      command: 2,
                      dest: 3,
                      msgid: 4,
                      rescode: 5)
  end

  def recv_msg(iddata, _call)
    Recv.new().each
  end
  
  def send_msg(data)
    data.each_remote_read do |senddata|
      time =  Process.clock_gettime(Process::CLOCK_MONOTONIC)
      senddata.T_2 = time

      lock_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      $send_lock += 1 if $array_mu.locked?
      #$array_mu.lock
      lock_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      #begin
        $array.push senddata
      #ensure
      #  $array_mu.unlock
      #end
      $send_lock_time.push [lock_start, lock_end]
    end
    
    Msg::Response.new(length: 1,
                      command: 2,
                      dest: 3,
                      msgid: 4,
                      rescode: 5)
  end
end

def main ()
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(MsgServer.new())

  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

main


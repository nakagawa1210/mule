require 'fiddle/import'

MSG_PAYLOAD_LEN = 1024
MSG_TOTAL_LEN = M::Message.size

module M
  extend Fiddle::Importer
  dlload "libc.so.6"
  extern "int gettimeofday(void*, void*)"
  Messeage = struct(["uint tot_len",
                     "uint msg_type", 
                     "uint ws",
                     "uint saddr",
                     "uint daddr",
                     "uint64_t sender_send_time",
                     "uint64_t server_recv_time",
                     "uint64_t server_send_time",
                     "uint64_t recver_recv_time",
                     "char[MSG_PAYLOAD_LEN] payload"])
end

def main
  send_data = M::Messeage.malloc
  p send_data.tot_len = MSG_PAYLOAD_LEN
  p send_data
end

main

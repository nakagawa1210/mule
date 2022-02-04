require "csv"

MAX_COUNT = 100000

def per (val, all_val)
   return val.to_f * 100 / all_val.to_f
end

def main
  data_sum = Array.new(8, 0.0)
  time = Array.new(4, 0.0)

  file_list = CSV.read('log/latest_file.log')

  file_list.each do |filename|
    server_logname = filename[0].clone.insert(-4,"server")
    server_logname = "log/" + server_logname
    recv_logname = filename[0].clone.insert(-4,"recv")
    recv_logname = "log/" + recv_logname
    send_logname = filename[0].clone.insert(-4,"send")
    send_logname = "log/" + send_logname

    server_log = CSV.read(server_logname)
    send_log = CSV.read(send_logname)
    recv_log = CSV.read(recv_logname)
    recv_log.shift

    #MAX_COUNT.times do |i|
    #  puts "#{i},#{send_log[i][1]},#{recv_log[i][1]},#{recv_log[i][2]},#{server_log[i][1]},#{server_log[i][3]},#{recv_log[i][3]},#{recv_log[i][4]},#{recv_log[i][6]}"
    #end

    MAX_COUNT.times do |i|
      data_sum[0] += recv_log[i][1].to_f - send_log[i][1].to_f
      data_sum[1] += recv_log[i][2].to_f - recv_log[i][1].to_f
      data_sum[2] += server_log[i][1].to_f - recv_log[i][2].to_f
      data_sum[3] += server_log[i][3].to_f - server_log[i][1].to_f

      data_sum[4] += recv_log[i][3].to_f - server_log[i][3].to_f
      data_sum[5] += recv_log[i][4].to_f - recv_log[i][3].to_f
      data_sum[6] += recv_log[i][6].to_f - recv_log[i][4].to_f

      data_sum[7] += recv_log[i][6].to_f - send_log[i][1].to_f
    end

    puts "#{filename[0].slice(10..13)},#{per(data_sum[0], data_sum[7])}%,#{per(data_sum[1], data_sum[7])}%,#{per(data_sum[2], data_sum[7])}%,#{per(data_sum[3], data_sum[7])}%,#{per(data_sum[4], data_sum[7])}%,#{per(data_sum[5], data_sum[7])}%,#{per(data_sum[6], data_sum[7])}%"
    puts " ,#{data_sum[0]},#{data_sum[1]},#{data_sum[2]},#{data_sum[3]},#{data_sum[4]},#{data_sum[5]},#{data_sum[6]},#{data_sum[7]}"

    time[0] = recv_log[MAX_COUNT-1][1].to_f - recv_log[0][1].to_f
    time[1] = recv_log[MAX_COUNT-1][2].to_f - recv_log[0][2].to_f
    time[2] = recv_log[MAX_COUNT-1][3].to_f - recv_log[0][3].to_f
    time[3] = recv_log[MAX_COUNT-1][4].to_f - recv_log[0][4].to_f
    puts "#{time[0]},#{time[1]},#{time[2]},#{time[3]}"
  end
end

main

require "csv"

def per (val, all_val)
   return val.to_f * 100 / all_val.to_f
end

def main
  @data_sum = Array.new(15, 0.0)

  file_log = ARGV.size > 0 ?  ARGV[0] : exit #read TIME.log file
  file_diff = 'log/' + file_log + '.diff'

  data_list = CSV.read(file_diff)
  sp_file = file_log.split(".")
  filename = 'log/' + sp_file[0] + '.perlog'
  
  CSV.open(filename,'w') do |file|
    data_list.each do |data|
      15.times do |i|
        @data_sum[i] += data[i].to_f
      end
    end
    file<<[per(@data_sum[0],@data_sum[3]),per(@data_sum[1],@data_sum[3]),
           per(@data_sum[2],@data_sum[3]),
           per(@data_sum[4],@data_sum[8]),per(@data_sum[5],@data_sum[8]),
           per(@data_sum[6],@data_sum[8]),per(@data_sum[7],@data_sum[8]),
           per(@data_sum[9],@data_sum[14]),per(@data_sum[10],@data_sum[14]),
           per(@data_sum[11],@data_sum[14]),per(@data_sum[12],@data_sum[14]),
           per(@data_sum[13],@data_sum[14])]
  end
  puts filename
end                                                       
                                                          
main

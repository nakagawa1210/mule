require "csv"

def per (val, all_val)
   return val.to_f * 100 / all_val.to_f
end

def main
  @data_sum = Array.new(4, 0.0)

  file_log = ARGV.size > 0 ?  ARGV[0] : exit #read TIME.log file
  file_csv = 'log/' + file_log + '.csv'

  data_list = CSV.read(file_csv)
  sp_file = file_log.split(".")
  filename = 'log/' + sp_file[0] + '.perlog'
  
  CSV.open(filename,'w') do |file|
    data_list.each do |data|
      4.times do |i|
        @data_sum[i] += data[i+1].to_f
      end
    end
    file<<[per(@data_sum[0],@data_sum[3]),
           per(@data_sum[1],@data_sum[3]),
           per(@data_sum[2],@data_sum[3])]
  end
  puts filename
end                                                       
                                                          
main

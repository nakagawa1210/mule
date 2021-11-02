require "csv"
                                                          
def main
  file = ARGV.size > 0 ?  ARGV[0] : exit
  data_list = CSV.read(file)
  time = Time.now.strftime("%Y%m%d_%H%M")
  puts filename = 'log/time_' + time + '.perlog'
  CSV.open(filename,'w') do |test|
    data_list.each_slice(2) do |name, data|
      sp_file = name[0].split("_")
      winsize = sp_file[2]
      msgsize = sp_file[4]
      
      test << ["\t" + winsize + 
               "\t" + msgsize + 
               "\t" + data[0].to_f.round(5).to_s + 
               "\t" + data[1].to_f.round(5).to_s + 
               "\t" + data[2].to_f.round(5).to_s]
    end
  end
end
                                                          
main

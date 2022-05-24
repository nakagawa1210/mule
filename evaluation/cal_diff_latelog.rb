require "csv"

def cal_diff(file)
  data =[]
  data_list = CSV.read(file)
  p filename = file + '.csv'
  CSV.open(filename,'w') do |diff_file|
    data_list.each.with_index(1) do |data,i|
      diff_file << [i,
               data[2].to_f - data[1].to_f,
               data[3].to_f - data[2].to_f,
               data[4].to_f - data[3].to_f,
               data[4].to_f - data[1].to_f]
    end
  end
end

def main
  file = ARGV.size > 0 ?  ARGV[0] : exit
  file_list = CSV.read("log/latest_file.log")
  file_dir = "log/"
  file_list.each do |file_name|
    file_path = file_dir + file_name[0]
    cal_diff(file_path)
  end
end

main

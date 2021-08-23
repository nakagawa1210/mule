require "csv"
def main
  file1 = ARGV.size > 0 ?  ARGV[0] : exit
  file2 = ARGV.size > 1 ?  ARGV[1] : exit

  push_data =[]
  data_1 = CSV.read(file1)
  data_1.shift
  data_2 = CSV.read(file2)

  filename = file2 + '.csv'
  CSV.open(filename,'w') do |file|
    file << data_2.shift
    data_1.zip(data_2).each do |d_1, d_2|
      file<<[d_1[1].to_f,d_1[2].to_f,d_2[0].to_f,d_2[1].to_f,d_2[2].to_f,
             d_2[3].to_f,d_2[4].to_f,d_2[5].to_f,d_2[6].to_f,d_1[3].to_f,d_1[4].to_f]
    end
  end
end

main

require "csv"

def main
  file = ARGV.size > 0 ?  ARGV[0] : exit
  file = 'log/' + file
  data =[]
  csv_data_list = CSV.read(file + '.csv')
  file.insert(-4,'len')
  data_list = CSV.read(file)
  filename = file + '.csv'
  CSV.open(filename,'w') do |test|
    test << csv_data_list.shift
    csv_data_list.each.with_index(1) do |data,i|
      test << [data[0],
               data[1].to_f,data[2].to_f,
               data[3].to_f,data[4].to_f,
               data_list[i][1].to_f - data_list[i][0].to_f,
               data_list[i][3].to_f - data_list[i][2].to_f]
    end
  end
end

main

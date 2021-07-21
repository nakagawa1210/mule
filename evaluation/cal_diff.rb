require "csv"
def diff (val_1, val_2)
  return val_2 - val_1
end

def main
  file = ARGV.size > 0 ?  ARGV[0] : exit
  file = 'log/' + file
  data =[]
  csv_data_list = CSV.read(file + '.csv')
  filename = file + '.diff'
  CSV.open(filename,'w') do |test|
    csv_data_list.shift
    csv_data_list.each do |data|
      test << [diff(data[0].to_f,data[1].to_f),
               diff(data[1].to_f,data[9].to_f),
               diff(data[9].to_f,data[10].to_f),
               diff(data[0].to_f,data[10].to_f),
               diff(data[0].to_f,data[1].to_f),
               diff(data[1].to_f,data[2].to_f),
               diff(data[2].to_f,data[3].to_f),
               diff(data[3].to_f,data[4].to_f),
               diff(data[0].to_f,data[4].to_f),
               diff(data[5].to_f,data[6].to_f),
               diff(data[6].to_f,data[7].to_f),
               diff(data[7].to_f,data[8].to_f),
               diff(data[8].to_f,data[9].to_f),
               diff(data[9].to_f,data[10].to_f),
               diff(data[5].to_f,data[10].to_f)]
    end
  end
end

main

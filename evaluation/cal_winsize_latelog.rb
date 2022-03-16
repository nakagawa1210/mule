require "csv"

def cal_diff(file)
  @start = 0
  @end = 0
  data_list = CSV.read(file)
  data_list.shift
  data_list.each.with_index(1) do |data, i|
    if i == 1 then
      @start = data[1].to_f
    elsif i == data_list.length then
      @end = data[4].to_f
    end
  end

  winpartfile = file.split(/_/)
  _partfile = winpartfile[2].partition("-")
  winsize = _partfile[0].to_i

  return [winsize,1,@end - @start]
end

def main
  @start = 0
  @end = 0

  time = ARGV[0].to_s

  log_list = CSV.read('log/latest_file.log')

  datalist = Array.new(log_list.length){Array.new(4,0)}

  win_list = []

  log_list.each do |file|
    p filename = 'log/' + file[0]
    record = cal_diff(filename)

    winsize = record[0].to_i

    unless win_list.include?(winsize) then
      win_list.push winsize
    end

    num = win_list.index(winsize)

    if record[1].to_i == 1 then
      datalist[num][1] = record[2].to_f
    elsif record[1].to_i == 2 then
      datalist[num][2] = record[2].to_f
    else
      datalist[num][3] = record[2].to_f
    end

    datalist[num][0] = winsize
  end

  putfilename = 'log/win_time_' + time + '.log'
  CSV.open(putfilename,'w') do |test|
    datalist.each do |data|
      next if data[0] == 0
      test << [data[0],data[1].to_f,data[2].to_f,data[3].to_f]
    end
  end

  putfilename = 'log/win_gbps_' + time + '.log'
  CSV.open(putfilename,'w') do |test|
    datalist.each do |data|
      next if data[0] == 0
      test << [data[0],
               (8*1024) / (data[1].to_f * 10000),
               (8*2048) / (data[2].to_f * 10000),
               (8*4096) / (data[3].to_f * 10000)]
    end
  end
end

main

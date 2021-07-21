#!/bin/bash

TIME=$(date "+%Y%m%d_%H%M")

ruby cal_winsize.rb $TIME

gnuplot -persist <<-EOFMarker
set datafile separator ","
set xlabel 'Windowsize'
set ylabel 'Sec'

set key right top
plot [] [0:]"log/win_time_$TIME.log" using 1:2 title "1KB" with lines
replot "log/win_time_$TIME.log" using 1:3 title "2KB" with lines
replot "log/win_time_$TIME.log" using 1:4 title "4KB" with lines
set terminal png
set output "log/graph/win_time_$TIME.png"
replot
EOFMarker
#set logscale x
gnuplot -persist <<-EOFMarker
set datafile separator ","
set xlabel 'Windowsize'
set ylabel 'gbps'

set key left top
plot [] [0:] "log/win_gbps_$TIME.log" using 1:2 title "1KB" with lines
replot "log/win_gbps_$TIME.log" using 1:3 title "2KB" with lines
replot "log/win_gbps_$TIME.log" using 1:4 title "4KB" with lines
set terminal png
set output "log/graph/win_gbps_$TIME.png"
replot
EOFMarker
#set logscale x

#!/bin/bash
#while read filename
#do
#    echo $filename
#    
#    ruby ~/mule/evaluation/cal_diff.rb $filename
#
#done < log/latest_file.log

while read filename
do
    echo $filename
    
    ruby ~/mule/evaluation/cal_percent.rb $filename >> log/per_file.log

done < log/latest_file.log

while read filename
do
    echo $filename >> log/per_sum_file.log

    cat $filename | tail -n 1 >> log/per_sum_file.log

done < log/per_file.log

ruby ~/mule/evaluation/fc_for_per.rb log/per_sum_file.log

:>| log/per_file.log
:>| log/per_sum_file.log

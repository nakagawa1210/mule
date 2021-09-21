#!/bin/bash
DIR=$1
:>| ~/mule/services/$DIR/log/latest_file.log
:>| ~/mule/services/$DIR/log/latest_file.mulog
:>| ~/mule/services/$DIR/log/latest_file.latelog

#!/bin/bash

file_name="$1"
line_num=$2

echo $(cat $file_name | head -$line_num | tail -1)

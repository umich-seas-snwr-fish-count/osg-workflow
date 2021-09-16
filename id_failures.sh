#!/bin/bash

if [ $# -ne 1 ] ; then
    echo "Missing required argument which is a job number"
    exit 1
else 
    jobnum=$1
fi

i=1
for file in $(cat convert_2020_11.txt.long.rerun) ; do
    outfile=${jobnum}-out/aris-${jobnum}.$((i-1)).out
    printf "%5s  %s " $i $file
    grep -q 'upload:' $outfile
    if [ $? -eq 0 ] ; then
        echo "OK"
    else
        echo "FAIL"
    fi
    i=$((i+1))
done

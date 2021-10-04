#!/bin/bash

if [ $# -ne 2 ] ; then
    echo -e "\n$0 takes two arguments, two-digit month and four-digit year; e.g."
    echo -e "Example: $0 $0 11 2020\n"
    exit 1
fi

echo $1 | egrep '[0-9][0-9]' > /dev/null
rc=$?
if [ $rc -eq 0 ] ; then
    export month=$1
else
    echo "The month, $1, is not a two-digit number"
    exit 1
fi

echo $2 | egrep '[0-9][0-9][0-9][0-9]'
rc=$?

if [ $rc -eq 0 ] ; then
    export year=$2
else
    echo "The year, $2, is not a four-digit number"
    exit 1
fi

# Load the s3cmd module
module purge
module load s3cmd 2>/dev/null

# Directory where the video files go
export video=/scratch/seelbach_root/seelbach1/shared_data/$year/mp4

# The convert_YYYY_MM.txt files were created by make_a_month at OSG and
# should be included in this repository.  Make sure to git pull origin main
# to get any new ones.

for file in $(cat convert_${year}_${month}.txt) ; do
    # This is what a line from convert_${year}_${month}.txt looks like
    # s3://testcou-seas-sonar-images/ARIS_2020_11_13/2020-11-13_230000.aris
    # Convert first to OSiRIS video file location, then to GL /scratch location
    s3_mp4=$(echo $file | sed 's/sonar/video/ ; s/ARIS_//; s/\.aris/.mp4/')
    mp4=$(echo $file | sed 's#s3://testcou-seas-sonar-images/##; s/ARIS_//; s/\.aris/.mp4/')
    # If the file doesn't exist on GL, get it, otherwise show its listing
    if [ ! -s $video/$mp4 ] ; then
       s3cmd get $s3_mp4 $video/$mp4
    else
        ls -l $video/$mp4
    fi
done


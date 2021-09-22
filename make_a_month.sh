#!/bin/bash

if [ $# -ne 2 ] ; then
    echo "$0 takes two arguments, two-digit month and four-digit year; e.g."
    echo "    $0 11 2020"
    echo
    exit 1
fi

echo $1 | egrep '[0-9][0-9]'
rc=$?
if [ $rc -eq 0 ] ; then
    export MO=$1
else
    echo "The month, $MO, is not a two-digit number"
    exit 1
fi

echo YR | egrep '[0-9][0-9][0-9][0-9]'
rc=$?
if [ $rc -eq 0 ] ; then
    export YR=$2
else
    echo "The year, $YR, is not a four-digit number"
    exit 1
fi

export img="/cvmfs/singularity.opensciencegrid.org/arburks/aris-convert:latest"
export s3cmd="singularity exec $img s3cmd"
export convert="singularity exec $img python3 /opt/aris_convert.py"

if [ -s "convert_${YR}_${MO}.txt" ] ; then
    ls -l convert_${YR}_${MO}.txt
    echo -n "convert_${YR}_${MO}.txt exists.  Overwrite [y/n]?  "
    read x
    if [ "$(echo ${x,,}x | cut -c 1)" == 'y' ] ; then
        rm -f convert_${YR}_${MO}.txt
    else
        echo "You replied with something other than 'y'.  Bye."
        # exit 1
    fi
fi


# Get the list of days in the month
days=$(s3cmd ls s3://testcou-seas-sonar-images/ | awk '{ print $NF }' | grep "ARIS_${YR}_${MO}_")

# Get the list of files for that day
for day in $days ; do
    echo ""
    # for each of the files
    for file in $(s3cmd ls $day | awk '{ print $NF }') ; do
        video=$(echo $file | sed 's/sonar/video/ ; s/\.aris/.mp4/; s/ARIS_//')
        echo $file | tee -a convert_${YR}_${MO}.txt
        # out=$(echo $day | awk -F/ '{ print $(NF-1) }' | sed 's/ARIS_//')
        # echo $convert --output $PWD $(echo $file | awk -F/ '{ print $NF }')
        # echo "$s3cmd put $video"
        # echo ""
    done
done



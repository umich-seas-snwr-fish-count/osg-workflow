#!/bin/bash

# This script will identify failed .aris file conversions by converting the
# .aris filename to the corresponding .mp4 filename and then asking OSiRIS
# whether the .mp4 file exists

if [ $# -ne 1 ] ; then
    echo "Wrong number of arguments"
    echo "Usage:  $0 [fname]"
    echo "    where fname is the file containing the .aris files that should have been"
    echo "    converted."
    exit 1
else
    if [ -s $1 ] ; then
        aris_list=$1
        aris_reruns="$1.rerun"
    else
        echo "$1 does not exist or is empty"
        exit 1
    fi
fi

# Check for the s3cmd program and exit if unavailable
which s3cmd 2>/dev/null
rc=$?
if [ $rc -ne 0 ] ; then
    echo "s3cmd command not found.  You may need to run this script from singularity"
    echo "Exiting."
    exit 1
fi

echo
echo "The file containing .aris files that should have been converted is"
echo -n "    "
ls -ld $aris_list
echo

# Make sure we have an empty reruns file
rm -f $aris_reruns
touch $aris_reruns
reruns=0

for aris in $(cat $aris_list) ; do
    mp4=$(echo $aris | sed 's/sonar/video/ ; s/ARIS_//; s/\.aris/.mp4/')
    check=$(s3cmd ls $mp4)
    echo $check | grep -q $mp4
    rc=$?
    if [ $rc -ne 0 ] ; then
        echo "$aris  ->  $mp4  FAILED"
        echo $aris >> $aris_reruns
        reruns=1
#     else
#         echo "$aris  ->  $mp4  OK"
    fi
done

if [ $reruns -eq 1 ] ; then
    echo "The list of .aris images that need to be rerun is in"
    ls -l $aris_reruns
fi


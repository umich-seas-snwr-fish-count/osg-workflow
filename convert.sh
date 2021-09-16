#!/bin/bash

if [ $# -ne 1 ] ; then
    echo "You forgot to specify the file, or gave me too many, to convert!"
    exit 1
fi

export arisData="$1"

export img="/cvmfs/singularity.opensciencegrid.org/arburks/aris-convert:latest"
export s3cmd="singularity exec $img s3cmd"
export convert="singularity exec $img python3 /opt/aris_convert.py"

video=$(echo $arisData | sed 's/sonar/video/ ; s/\.aris/.mp4/; s/ARIS_//')
file=$(echo $arisData | awk -F/ '{ print $NF }')

echo "#---- Starting time: $(date)"
echo -e "\nCopying $arisData from OSiRIS"
# $s3cmd get $arisData
s3cmd get $arisData

echo "#---- Starting conversion at $(date)"
echo -e "\nConverting $arisData"
# $convert --cores 4 --output $PWD --input $file
python3 /opt/aris_convert.py --cores 4 --output $PWD --input $file

echo "#---- Starting upload at $(date)"
echo -e "\nUploading MP4 file $video"
# $s3cmd put $(echo $arisData | sed 's/\.aris/.mp4/') $video 
s3cmd put --force $(echo $file | sed 's/\.aris/.mp4/') $video 

echo -e "\nSetting permissions on {video}"
for user in arburks@umich.edu bennet@umich.edu jshelly@umich.edu \
            kayleegs@umich.edu kuiran@umich.edu ; do \
    s3cmd setacl --acl-grant full_control:${user} ${video}
done

echo -e "Removing $(echo $arisData | sed 's/\.aris/.mp4/') and $file"
rm -rf $(echo $file | sed 's/\.aris/.mp4/') $file

echo "#---- Stopping time: $(date)"

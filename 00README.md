# Guide to the files

## Scripts

make_a_month.sh : This script creates the file containing one month's .aris files

convert.sh : This script downloads the .aris file from OSiRIS, converts it to
             .mp4, uploads the .mp4 to OSiRIS, and removes the .aris and .mp4
             from the local directory.

convert.sub : This is the HTCondor submit script; the final line needs to be changed
              when a new month's .aris files are being run, or if there are failed
              conversion jobs that need to be rerun.

id_failures.sh : This script uses the same file as convert.sub that contains the
                 .aris files submitted for that job and checks in the output
                 directory looking for text that indicates a successful upload
                 of a .mp4 file to OSiRIS.
                

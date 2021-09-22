# SNWR fish census project

This repository documents the workflow for the project to count and
identify fish passing monitoring sites in the Shiawassee National Wildlife
refuge.

## From ARIS field instruments to video files: summary

* The data is copied from the ARIS instrument to USB portable hard drive.
* The hard drive is delivered to UM Ann Arbor campus, where it is copied
  to the Great Lakes cluster `/scratch/seelbach_root/seelbach1/shared_data`
  folder using Globus from a computer in SEAS.
* Raw ARIS data is copied from the Great Lakes cluster to the USGS Black
  Pearl device.
* The program to check for corrupted `.aris` file should be run on Great Lakes
  to identify any `.aris` files that need to be repaired with `ARIScope`.
  Corrupted files should be repaired and copied to Great Lakes prior to
  the next step.  See [URL] for how to obtain, install, and run `arisCheck.py`.
* Raw ARIS data is copied from the Black Pearl device to another disk array
  at the USGS HPC center in Sioux Falls, SD.
* Processing at Open Science Grid (OSG)
    * Raw ARIS data is copied from the Great Lakes cluster to OSiRIS.
    * On the OSG login node, a list of the data files for the month to be
      processed is created using the script `make_a_month.sh`.
    * The HTCondor job submit script, `convert.sub` is modified to use the
      list of files for the month to be processed.
    * The HTCondor job is submitted.
    * The list of .aris files for each ARIS file is used to check that there
      is an `.mp4` file for each and missing files are flagged by running the
      `id_failures.sh` script, which takes one argument, the name of the file
      that contained the `.aris` files to convert.  For example,
      ```
      $ ./id_failures.sh convert_2020_11.txt
      ```
      If there are missing `.mp4` files, the script will create a list to use
      for reprocessing called, using the example above,
      `convert_2020_11.txt.rerun`.
    * Any ARIS files for which no `.mp4` file was created gets added to a list
      of ARIS files to rerun.  That list is submitted to HTCondor.
    * The above two steps repeat until the entire month is completely processed
      and there is a `.mp4` file for every `.aris` file.
    * A directory is created for the HTCondor log files and for the output
      files for each job, and the log files and output files are copied to
      them.
    * At Great Lakes, the `.mp4` files are copied from OSiRIS to the `/scratch`
      directory for that month.
* Processing at Sioux Falls HPC
    * Raw data is copied from the Black Pearl or Sioux Falls storage to
      a working directory.
    * A job script is created to process the data for that month and submitted.
    * A check is run to insure that for every `.aris` file there is a `.mp4`
      file; jobs are created for missing files and rerun.
* The `.mp4` files are copied to the Black Pearl.
* The `.mp4` files are copied from the Black Pearl to the Sioux Falls HPC
  storage.


#!/bin/bash
#SBATCH -J quadfigure
#SBATCH -n 1                # Number of cores
#SBATCH -N 1                # Ensure that all cores are on one machine
#SBATCH -t 0-01:00        # Runtime in D-HH:MM, minimum of 10 minutes
#SBATCH -p ncf   # Partition to submit to
#SBATCH --mem=6GB           # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o %j.out  # File to which STDOUT will be written, %j inserts jobid
#SBATCH -e %j.err  # File to which STDERR will be written, %j inserts jobid

module load freesurfer/6.0.0-fasrc01

xvfb-run -a --server-args "-screen 0 1920x1080x24" -e /dev/stderr ./quadfigure.sh $1

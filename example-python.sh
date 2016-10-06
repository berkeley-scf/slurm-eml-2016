#!/bin/bash
# Job name:
#SBATCH --job-name=python-test
#
# optional but please include if possible
# Wall clock limit (3 minutes here):
#SBATCH --time=00:30:00
#
#SBATCH --cpus-per-task=8
#
## Command(s) to run:
# to be safe that we get the Python version we want
module unload python
module load python/3
ipcluster start -n $SLURM_CPUS_PER_TASK &
cd ~
ipython < parallel.py
ipcluster stop

#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Number of MPI tasks needed for use case:
#SBATCH --ntasks=1
#
# Processors per task:
#SBATCH --cpus-per-task=8
#
# Wall clock limit (30 seconds here):
#SBATCH --time=00:00:30
#
## Command(s) to run:
stata-mp -b do code.do 

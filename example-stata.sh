#!/bin/bash
# Job name:
#SBATCH --job-name=stata-test
#
# optional but please include if possible
# Wall clock limit (3 minutes here):
#SBATCH --time=00:03:00
#
#SBATCH --cpus-per-task=8
## Command(s) to run:
stata-mp -b do code.do 

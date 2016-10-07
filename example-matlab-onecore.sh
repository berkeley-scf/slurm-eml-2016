#!/bin/bash
# Job name:
#SBATCH --job-name=matlab-test
#
# optional but please include if possible
# Wall clock limit (3 minutes here):
#SBATCH --time=00:30:00
#
## Command(s) to run:
matlab -singleCompThread  -nodesktop -nodisplay < code.m > code.mout

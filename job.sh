#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# optional but please include if possible
# Wall clock limit (3 minutes here):
#SBATCH --time=00:03:00
#
## Command(s) to run:
python calc.py >& calc.out

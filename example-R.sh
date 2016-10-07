#!/bin/bash
# Job name:
#SBATCH --job-name=R-test
#
# Wall clock limit (30 minutes here):
#SBATCH --time=00:30:00
#
#SBATCH --cpus-per-task=8
#
## Command(s) to run:
R CMD BATCH --no-save parallel.R parallel.Rout

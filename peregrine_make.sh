#!/bin/bash
#
# make this project on Peregrine, by loading the required modules first.
#
# Usage (in queue, preferred):
#
#   sbatch ./peregrine_make.sh
#
# Usage (local):
#
#   ./peregrine_make.sh
#
#
# Peregrine directives:
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --job-name=peregrine_make
#SBATCH --output=peregrine_make.log
module load R Python
make peregrine

#!/bin/bash

# Submit the python script 01_mC_genes_TEs.py as a SLURM job
# Tom Ellis 2nd November 2023

#SBATCH --job-name=mC_genes_TEs
#SBATCH --qos=medium
#SBATCH --time=24:00:00
#SBATCH --mem=80gb
#SBATCH --output=03_analysis/04_methylation_status/slurm/%x.out
#SBATCH --error=03_analysis/04_methylation_status/slurm/%x.err

module load build-env/f2022
module load anaconda3/2023.03
source ~/.bashrc
conda activate epiclines

date

mkdir -p 03_analysis/04_methylation_status/output

python 03_analysis/04_methylation_status/01_mC_genes_TEs.py

date
#!/bin/bash

# Submit the python script 01_mC_genes_TEs.py as a SLURM job
# Tom Ellis

#SBATCH --job-name=mC_genes_TEs
#SBATCH --qos=short
#SBATCH --time=8:00:00
#SBATCH --mem=80gb
#SBATCH --output=03_analysis/04_methylation_status/slurm/%x.out
#SBATCH --error=03_analysis/04_methylation_status/slurm/%x.err

module load build-env/f2022
module load anaconda3/2023.03
source ~/.bashrc
conda activate epiclines

date

mkdir -p 05_results/13_identifying_te_methylation
python 05_results/13_identifying_te_methylation/01_get_methylation_counts.py

date
#!/bin/bash

# Calculate non-conversion in 150bp windows across the chloroplasts of four
# Columbia samples.

# Tom Ellis, 31st October 2023

#SBATCH --job-name=col0_windows
#SBATCH --output=03_analysis/02_across_chloroplast/slurm/%x-%a.out
#SBATCH --error=03_analysis/02_across_chloroplast/slurm/%x-%a.err
#SBATCH --qos=short
#SBATCH --time=8:00:00
#SBATCH --mem=10gb
#SBATCH --array=0-3

# Load conda environment and set working directory, if used. 
source setup.sh

date

files=(02_processing/02_align_reads/columbia/output/reports/*CX_report.txt.gz)
infile=${files[$SLURM_ARRAY_TASK_ID]}

outdir=03_analysis/02_across_chloroplast/output
mkdir -p $outdir

outfile=$(basename ${infile/CX_report.txt.gz/windows.csv})

python 03_analysis/02_across_chloroplast/01_mC_in_windows.py \
    --input $infile \
    --output $outdir/$outfile \
    --window 150 \
    --chromosome "chloroplast"

date
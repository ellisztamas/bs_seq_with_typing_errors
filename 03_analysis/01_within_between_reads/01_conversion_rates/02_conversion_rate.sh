#!/bin/bash

# Calculate conversion rate on each chromosome.
#
# Applies the script `01_conversion_rates.py` to each cytosine report file for
# Columbia and Drosophila samples. These samples also contain information on the
# NEB Lambda phage.
# It returns a CSV file giving methylation level on each chromosome in the report
# file (i.e. every key header in the FASTA file to which reads were mapped).
# 
# Note that the Drosophila 6 genome still consists of many, many contigs, so
# there will be many, many rows.
# 
# Tom Ellis, 30th October 2023

#SBATCH --job-name=non-conversion_rates
#SBATCH --output=03_analysis/01_within_between_reads/01_conversion_rates/slurm/%x-%a.out
#SBATCH --error=03_analysis/01_within_between_reads/01_conversion_rates/slurm/%x-%a.err
#SBATCH --qos=rapid
#SBATCH --time=1:00:00
#SBATCH --mem=30gb
#SBATCH --array=0-11

# Load conda environment and set working directory, if used. 
source setup.sh

date

files=(02_processing/02_align_reads/**/output/reports/[CF]*CX_report.txt.gz)
infile=${files[$SLURM_ARRAY_TASK_ID]}

outdir=03_analysis/01_within_between_reads/01_conversion_rates/output
mkdir -p $outdir

outfile=$(basename ${infile/CX_report.txt.gz/conversion.csv})

python 03_analysis/01_within_between_reads/01_conversion_rates/01_conversion_rate.py \
    --input $infile \
    --output $outdir/$outfile

date



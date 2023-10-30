#!/bin/bash

# Map bisulphite short reads to the TAIR reference genome.
#
# The pipeline requires raw data to be in fastq.gz format, and a sample sheet stating
# how sample names line up with files. These are created with other scripts in 
# this folder. 
#
# Note that the script hard codes various optional arguments to trim galore and
# Bismark - check that script for which arguments are used.

# Tom Ellis, 19th September 2023

#SBATCH --job-name=align_cross
#SBATCH --output=02_processing/02_align_reads/cross/slurm/%x-%a.out
#SBATCH --error=02_processing/02_align_reads/cross/slurm/%x-%a.err
#SBATCH --time=1-00:00
#SBATCH -N 1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=10G
#SBATCH --qos=medium
#SBATCH --array=1,2,3,4,6,13,32,37,41,42,44,47,48,38,49,53,59,69-72,64,73,82,83,89,94-96,87 #1-96 # Start at 1, because the sample sheet has a header row


module load build-env/f2022
module load anaconda3/2023.03
source $EBROOTANACONDA3/etc/profile.d/conda.sh
conda activate epiclines

# working directory
scratch=/scratch-cbe/users/$(whoami)/cross
# output directory
outdir=02_processing/02_align_reads/cross/output
# FASTA file for the genome to map to
genome=02_processing/01_prepare_genomes/col0/TAIR10_plus_vectors.fa

# Sample sheet giving sample name and paths to the two fastq files
sample_sheet=02_processing/02_align_reads/cross/cross_sample_sheet.csv
# Get the sample name
sample_names=$(cut -d',' -f1 $sample_sheet)
sample_names=($sample_names)
# Path for read 1
read1_col=$(cut -d',' -f2 $sample_sheet)
read1_col=($read1_col)
# Path for read 2
read2_col=$(cut -d',' -f3 $sample_sheet)
read2_col=($read2_col)
# Additional options to pass to Trim Galore! and Bismark.
trim_galore_args="--clip_r1 15 --clip_r2 15 --three_prime_clip_R1 9 --three_prime_clip_R2 9 --cores 4"
bismark_args="--local --non_directional --strandID"
methylation_extractor_args="--cytosine_report --CX_context --no_header --no_overlap --comprehensive --gzip"

# Run the script
02_processing/02_align_reads/bismark_pipeline.sh \
    --sample "${sample_names[$SLURM_ARRAY_TASK_ID]}" \
    --read1  "${read1_col[$SLURM_ARRAY_TASK_ID]}" \
    --read2  "${read2_col[$SLURM_ARRAY_TASK_ID]}" \
    --genome $genome \
    --work $scratch \
    --outdir $outdir \
    --trim_galore_args "${trim_galore_args}" \
    --bismark_args "${bismark_args}" \
    --methylation_extractor_args "${methylation_extractor_args}"

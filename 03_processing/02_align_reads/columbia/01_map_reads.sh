#!/bin/bash

# Map bisulphite short reads for Columbia samples to the TAIR10 reference genome.

# This will only work if you have first unzipped the data!
# See 01_data/columbia_drosophila/unzip_tarball.sh 
#
# The pipeline requires raw data to be in fastq.gz format, and a sample sheet
# giving sample names, paths to two fastq files, and the path to the genome to 
# map to.
# In this case I created the sample sheets by hand.
#
# Note that the script hard codes various optional arguments to trim galore and
# Bismark - check that script for which arguments are used.

# Tom Ellis, 19th September 2023

#SBATCH --job-name=align_columbia
#SBATCH --output=03_processing/02_align_reads/columbia/slurm/%x-%a.out
#SBATCH --error=03_processing/02_align_reads/columbia/slurm/%x-%a.err
#SBATCH --time=1-00:00
#SBATCH -N 1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=10G
#SBATCH --qos=medium
#SBATCH --array=1-4 # Start at 1, because the sample sheet has a header row

module load build-env/f2022
module load anaconda3/2023.03
source $EBROOTANACONDA3/etc/profile.d/conda.sh
conda activate epiclines

# working directory
scratch=/scratch-cbe/users/$(whoami)/columbia
# output directory
outdir=03_processing/02_align_reads/columbia/output

# Sample sheet giving sample name and paths to the two fastq files
sample_sheet=03_processing/02_align_reads/columbia/col0_sample_sheet.csv
# Get the sample name
sample_names=$(cut -d',' -f1 $sample_sheet)
sample_names=($sample_names)
# Path for read 1
read1_col=$(cut -d',' -f2 $sample_sheet)
read1_col=($read1_col)
# Path for read 2
read2_col=$(cut -d',' -f3 $sample_sheet)
read2_col=($read2_col)
# Path to the genome in question
genome=03_processing/01_prepare_genomes/col0/dm6_plus_vectors_microbiome.fa

trim_galore_args="--clip_r1 15 --clip_r2 15 --three_prime_clip_R1 9 --three_prime_clip_R2 9 --cores 4"
bismark_args="--local --non_directional --strandID"
methylation_extractor_args="--cytosine_report --CX_context --no_header --no_overlap --comprehensive --gzip"

02_library/bismark_pipeline.sh \
    --sample "${sample_names[$SLURM_ARRAY_TASK_ID]}" \
    --read1  "${read1_col[$SLURM_ARRAY_TASK_ID]}" \
    --read2  "${read2_col[$SLURM_ARRAY_TASK_ID]}" \
    --genome $genome \
    --work $scratch \
    --outdir $outdir \
    --trim_galore_args "${trim_galore_args}" \
    --bismark_args "${bismark_args}" \
    --methylation_extractor_args "${methylation_extractor_args}"



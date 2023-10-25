#!/bin/bash

# Script to create fastq files that can be passed to Bismark

# This takes reads split across multiple files, merges and sorts them, then
# creates separate fastq files for each mate pair.
# These are saved to the scratch-cbe drive if the VBC clip cluster.

# Note that pairs of input bam files contain labels _1# and _2#, but this does not
# indicate mate pairs. However, the output fastq files contain the same labels, 
# and they *do* indicate mate pairs. This is not an ideal way to do this.

# Tom Ellis, July 2023

#SBATCH --job-name=cross_fastqs
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --qos=short
#SBATCH --time=4:00:00
#SBATCH --mem=40gb
#SBATCH --array=0-99
#SBATCH --output=03_processing/02_align_reads/cross/slurm/%x-%a.out
#SBATCH --error=03_processing/02_align_reads/cross/slurm/%x-%a.err

module load build-env/f2022
module load anaconda3/2023.03
source $EBROOTANACONDA3/etc/profile.d/conda.sh
conda activate epiclines

date
echo "Script to merge pairs of BAM files:"

# Get arrays of pairs of files
read_pair_1=(01_data/cross/*_1#*bam)
read_pair_2=(01_data/cross/*_2#*bam)

# Get a pair of reads for this job
infile1=${read_pair_1[$SLURM_ARRAY_TASK_ID]}
infile2=${read_pair_2[$SLURM_ARRAY_TASK_ID]}
echo $infile1
echo $infile2

# Set a working directory on scratch
workdir=/scratch-cbe/users/$(whoami)/cross

# Merge files.
# Swap file path and extension for output file
merged_bam=${infile1/'01_data/cross'/"$workdir/merged_bams"}
echo "Saving merged bam to "$merged_bam
mkdir -p $(dirname $merged_bam)
samtools merge -f -o $merged_bam $infile1 $infile2

# Sort the merged bam file
sorted_bam=${merged_bam/merged_bams/sorted_bam}
echo "Saving sorted bam to "$merged_bam
mkdir -p $(dirname $sorted_bam)
samtools sort -n -@ $(nproc) -o ${sorted_bam} ${merged_bam}

echo "Converting to two separate fastq files"
fastq1=${infile1/'01_data/cross'/"$workdir/fastq"}
fastq2=${infile2/'01_data/cross'/"$workdir/fastq"}
fastq1=${fastq1/.bam/.fastq}
fastq2=${fastq2/.bam/.fastq}
echo $fastq1
echo $fastq2
singleton=${merged_bam/merged_bams/singleton}
ambiguous=${merged_bam/merged_bams/ambiguous}
mkdir -p $(dirname $fastq1)
mkdir -p $(dirname $singleton)
mkdir -p $(dirname $ambiguous)
samtools fastq -@ $(nproc) -1 ${fastq1} -2 ${fastq2} -s ${singleton} -0 ${ambiguous} ${sorted_bam}

echo "Compressing the output for methylseq"
gzip $fastq1
gzip $fastq2

date
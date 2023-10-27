#!/bin/bash

# Remove dubious reads from aligned BAM files
#
# Convert deduplicated, sorted BAM files from the Bismark pipeline to SAM,
# remove reads for which all cytosines are methylated, then convert back to BAM.
# 
# Tom Ellis, 27th October 2023

#SBATCH --job-name=remove_dubious_reads
#SBATCH --output=02_processing/03_filter_dubious_reads/slurm/%x-%a.out
#SBATCH --error=02_processing/03_filter_dubious_reads/slurm/%x-%a.err
#SBATCH --qos=rapid
#SBATCH --time=1:00:00
#SBATCH --mem=60gb
#SBATCH --array=0-11

module load build-env/f2022
module load anaconda3/2023.03
source $EBROOTANACONDA3/etc/profile.d/conda.sh
conda activate epiclines

date

files=(02_processing/02_align_reads/**/output/sorted/[CF]*bam)

# SAM files
echo "Creating the SAM files."
samdir=02_processing/03_filter_dubious_reads/tmp/
mkdir -p $samdir
infile=${files[$SLURM_ARRAY_TASK_ID]}
unfiltered_sam=`basename ${infile/sortedByPos.bam/unfiltered.sam}`
samtools view -h $infile > $samdir/$unfiltered_sam

filtered_sam=`basename ${infile/sortedByPos.bam/filtered.sam}`
discarded_sam=`basename ${infile/sortedByPos.bam/discarded.sam}`

python 02_processing/03_filter_dubious_reads/01_remove_dubious_reads.py \
    --input $samdir/$unfiltered_sam \
    --output $samdir/$filtered_sam \
    --discard $samdir/$discarded_sam

# Directories to hold the filtered and excluded reads
filtered_dir=02_processing/03_filter_dubious_reads/filtered
mkdir -p $filtered_dir
discard_dir=02_processing/03_filter_dubious_reads/dicarded
mkdir -p $discard_dir
filtered_bam=`basename ${infile/sortedByPos.bam/filtered.bam}`
discarded_bam=`basename ${infile/sortedByPos.bam/discarded.bam}`

# Convert back to BAM and index
samtools view -bhf 0x2 $samdir/$filtered_sam > $filtered_dir/$filtered_bam
samtools sort -o $filtered_dir/$filtered_bam $filtered_dir/$filtered_bam
samtools index $filtered_dir/$filtered_bam

samtools view -bhf 0x2 $samdir/$discarded_sam > $discard_dir/$discarded_bam
samtools sort -o $discard_dir/$discarded_bam $discard_dir/$discarded_bam
samtools index $discard_dir/$discarded_bam

# tidy up
rm $samdir/$unfiltered_sam
rm $samdir/$filtered_sam
rm $samdir/$discarded_sam
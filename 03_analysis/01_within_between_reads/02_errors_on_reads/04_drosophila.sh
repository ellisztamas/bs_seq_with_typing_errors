#!/bin/bash

# Script to extract only reads mapping to the chloroplast for samples of Col-0,
# count how many erronesous methylated cytosines occur at each position along 
# a read, and where they map.

# Tom Ellis, 27th October 2023

#SBATCH --job-name=drosophila_read_errors
#SBATCH --output=03_analysis/02_errors_on_reads/slurm/%x-%a.out
#SBATCH --error=03_analysis/02_errors_on_reads/slurm/%x-%a.err
#SBATCH --qos=rapid
#SBATCH --time=1:00:00
#SBATCH --mem=60gb
#SBATCH --array=0-7

module load build-env/f2022
module load anaconda3/2023.03
source $EBROOTANACONDA3/etc/profile.d/conda.sh
conda activate epiclines

date

files=(02_processing/02_align_reads/drosophila/output/sorted/Fly*bam)

# SAM files
echo "Creating the SAM files."
samdir=03_analysis/02_errors_on_reads/tmp/
mkdir -p $samdir
infile=${files[$SLURM_ARRAY_TASK_ID]}
samfile=`basename ${infile/sortedByPos.bam/.sam}`
samtools view -f 0x2 -h $infile > $samdir/$samfile


outdir=03_analysis/02_errors_on_reads/output
mkdir -p $outdir
positions=${samfile/.sam/_positions.csv}
counts=${samfile/.sam/_counts.csv}
# Count the number of unconverted cytosines
python 03_analysis/02_errors_on_reads/01_count_errors.py \
--input $samdir/$samfile \
--output $outdir/$counts
# Count the positions of those errors
python 03_analysis/02_errors_on_reads/02_count_error_positions.py \
--input $samdir/$samfile \
--output $outdir/$positions

# Tidy up.
echo "Removing the SAM file."
rm $samdir/$samfile

date
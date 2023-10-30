#!/bin/bash

# Create cytosine reports for the filtered BAM files for which any reads on
# which all cytosines were methylated have been removed.
# This script is for the Drosophila samples only.
# 
# Tom Ellis, 30th October 2023

#SBATCH --job-name=flies_cxreport
#SBATCH --output=02_processing/03_filter_dubious_reads/slurm/%x-%a.out
#SBATCH --error=02_processing/03_filter_dubious_reads/slurm/%x-%a.err
#SBATCH --qos=rapid
#SBATCH --time=30:00
#SBATCH --mem=20gb
#SBATCH --array=0-7

module load build-env/f2022
module load anaconda3/2023.03
source $EBROOTANACONDA3/etc/profile.d/conda.sh
conda activate epiclines

files=(02_processing/03_filter_dubious_reads/filtered/Fly*.bam)
infile=${files[$SLURM_ARRAY_TASK_ID]}

outdir=02_processing/03_filter_dubious_reads/reports
genome_folder=02_processing/01_prepare_genomes/drosophila

bismark_methylation_extractor \
    --paired-end \
    --genome_folder $genome_folder \
    --cytosine_report \
    --CX_context \
    --comprehensive \
    --no_header \
    --no_overlap \
    --gzip \
    --output_dir $outdir \
    $infile

date

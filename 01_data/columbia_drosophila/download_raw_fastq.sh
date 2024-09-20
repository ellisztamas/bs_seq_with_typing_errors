#!/bin/bash

# Script to download raw short-read Illumina data for four A. thaliana and eight
# D. melanogaster samples from NCBI.
#
# Created based on this tutorial by Aleksandra Badaczewska:
# https://bioinformaticsworkbook.org/dataAcquisition/fileTransfer/sra.html#gsc.tab=0
#
# Note that this uses the packages sratoolkit, parallel and Entrez command line 
# tools.
#
# Input:
#    NCBI project number
# Output:
#    12 gzipped fastq files.

#SBATCH --job-name=download_raw_fastq
#SBATCH --output=slurm/%x.out
#SBATCH --error=slurm/%x.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --time=01:00:00

module load build-env/f2021
module load sra-toolkit/3.0.0-centos_linux64
module load parallel/20210322-gcccore-10.2.0

# source setup.sh

# === Inputs === $

project='PRJNA1155267'

# === Outputs === $

# Directory to store the output.
outdir=01_data/columbia_drosophila
# Table of data from NCBI
runinfo=$outdir/runinfo.csv
# List of SRR numbers
srr_numbers=$outdir/SRR_numbers.txt

# === Script === #

	
esearch -db sra -query $project | efetch -format runinfo > $runinfo
cat $runinfo | cut -d "," -f 1 | tail -n +2 > $srr_numbers

cat $srr_numbers | parallel fastq-dump --split-files --origfmt --gzip -X 1000 --outdir $outdir {}

rm $runinfo $srr_numbers
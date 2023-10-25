#!/bin/bash

# Script to sort the deduplicated BAM files from the methylseq pipeline
# Tom Ellis, 12th September 2023

#SBATCH --job-name=prepare_col0_genome
#SBATCH --time=20:00
#SBATCH --qos=rapid
#SBATCH --mem=10gb
#SBATCH --output=slurm/prepare_col0_genome.out
#SBATCH --error=slurm/prepare_col0_genome.err

module load build-env/f2022
module load anaconda3/2023.03
source ~/.bashrc
conda activate epiclines

outdir=03_processing/01_prepare_genomes/col0
mkdir -p $outdir
# Concatenate the D. melanogaster genome to the control DNA vectors and two bacteria
cat 01_data/03_reference_genome/TAIR10_chr_all.fas 01_data/07_vector_DNA/*fasta > $outdir/TAIR10_plus_vectors.fa

bismark_genome_preparation $outdir
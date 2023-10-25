#!/bin/bash

# Script to sort the deduplicated BAM files from the methylseq pipeline
# Tom Ellis, 12th September 2023

#SBATCH --job-name=prepare_drosophila_genome
#SBATCH --time=1:00:00
#SBATCH --qos=rapid
#SBATCH --mem=10gb
#SBATCH --output=slurm/prepare_drosophila_genome.out
#SBATCH --error=slurm/prepare_drosophila_genome.err

module load build-env/f2022
module load anaconda3/2023.03
source ~/.bashrc
conda activate epiclines

outdir=03_processing/01_prepare_genomes/drosophila/
mkdir -p $outdir
# Concatenate the D. melanogaster genome to the control DNA vectors and two bacteria
cat 01_data/06_fly_genome/GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna \
01_data/07_vector_DNA/*fasta \
01_data/10_microbiome/*fna > \
$outdir/dm6_plus_vectors_microbiome.fa

bismark_genome_preparation $outdir
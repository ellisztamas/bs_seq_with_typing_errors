#!/usr/bin/env bash
# 
# Tom Ellis
# Script to download the genome files.
# Note that for the lambda and pUC19 vectors I just downloaded them manually 

# Lambda phage was downloaded from:
# https://www.ncbi.nlm.nih.gov/nuccore/J02459

# pUC19 downloaded from
# https://zymoresearch.eu/products/methylated-non-methylated-puc19-dna-set

# SLURM
#SBATCH --job-name=download_genomes
#SBATCH --mem=20GB
#SBATCH --output=slurm/%x.out
#SBATCH --error=slurm/%x.err
#SBATCH --qos=rapid
#SBATCH --time=1:00:00

outdir=01_data/genomes

# Download *A. thaliana* reference genome*
fasta=https://www.arabidopsis.org/download_files/Genes/TAIR10_genome_release/TAIR10_chromosome_files/TAIR10_chr_all.fas.gz
wget -P $outdir $fasta
# *A. thaliana* Annotation file
at_annotation=https://www.arabidopsis.org/download_files/Genes/TAIR10_genome_release/TAIR10_gff3/TAIR10_GFF3_genes_transposons.gff
wget -P $outdir/TAIR10_gff3 $at_annotation

# Download D. melanogaster reference genome 6 to a temporary directory
download_link='https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/215/GCF_000001215.4_Release_6_plus_ISO1_MT/GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna.gz'
# Download and unzip
wget $download_link -P $outdir
gunzip $outdir/GCF_000001215.4_Release_6_plus_ISO1_MT_genomic.fna.gz

# Download Acetobacter genome to a temporary directory
download_link='https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/379/545/GCF_000379545.1_ASM37954v1/GCF_000379545.1_ASM37954v1_genomic.fna.gz'
# Download and unzip
wget $download_link -P $outdir
gunzip $outdir/GCF_000379545.1_ASM37954v1_genomic.fna.gz 

# Download Lactobacillus acidophillus genome to a temporary directory
download_link='https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/389/675/GCF_000389675.2_ASM38967v2/GCF_000389675.2_ASM38967v2_genomic.fna.gz'
# Download and unzip
wget $download_link -P $outdir
gunzip $outdir/GCF_000389675.2_ASM38967v2_genomic.fna.gz
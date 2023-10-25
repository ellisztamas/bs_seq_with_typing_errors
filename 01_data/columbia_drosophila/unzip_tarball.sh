#!/usr/bin/env bash
# 
# Tom Ellis
# Script to unzip each raw data file to the `scratch-cbe` drive
# on the VBC cluster.

# SLURM
#SBATCH --job-name=unzip_columbia_drosophila
#SBATCH --mem=20GB
#SBATCH --output=01_data/columbia_drosophila/%x.out
#SBATCH --error=01_data/columbia_drosophila/%x.err
#SBATCH --qos=rapid
#SBATCH --time=1:00:00

# Reference directories. Change these for your machine.
# Working directory to perform computations on the VBC cluster.
scratch=/scratch-cbe/users/thomas.ellis/05_col0_flies
mkdir -p $scratch

# Where the data are
# Location of the raw zip file on the VBC cluster
zipfile=01_data/columbia_drosophila/AACJNTVM5_0_R14907_20230206.tar.gz

# Unzip raw data
tar -xvC $scratch -f $zipfile


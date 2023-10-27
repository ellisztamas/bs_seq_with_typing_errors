# Script to line up the names of compressed fastq files with biological samples
# Creates a CSV file with a row for each sample, giving sample, path to the fastq
# file for read 1, and (if paired-end) the path to the fastq file for read 2.

# This uses the command align_fastq_with_plate_positions from epiclines_tools
# to identify filenames with matching adapter sequences, and looks the position 
# of those adapters up in a text file. See
# /groups/nordborg/projects/epiclines/001.library/epiclines_tools/

# Tom Ellis, 3rd July 2023

import pandas as pd
from glob import glob
import os

import epiclinestools as epi
print("Using epiclines version " + epi.__version__)

# File giving the experimental design with a ow for each sample, giving plate 
# ID, temperature, row and column, F2 vs parent, and direction.
design = pd.read_csv("01_data/cross/experimental_design.csv")
design['design_sample_id'] = design['sample'] +"_"+ design['row'] + design['col'].astype(str)

index_set = "01_data/cross/unique_nextera_dualxt_set2.csv"
# List of directories corresponding to each plate
# fastq files are divided by plate ID
path="/scratch-cbe/users/" + os.getlogin() + "/cross/fastq/"
# fastq_directories = glob(path)

# List the fastq files for the current plate
input_files = glob(path + '/*fastq.gz')
# There are four bam files with adaptor sequences in their names that don't belong
# They are likley to be extra samples Viktoria added
indices_to_remove = [ 'CGCTCAGTTCTCGTGGAGCG', 'TATCTGACCTCTACAAGATA', 'TTCTATGGTTGGCGAGATGG', 'CCTCGCAACCAATAGAGCAA' ]
# List comprehensive to keep input files if they *don't* match on of the above adaptor sequences
# The inner for loop checks each file name against each adaptor sequence
input_files = [ filename for filename in input_files if all([bad_index  not in filename for bad_index in indices_to_remove]) ]

# Get plate positions
sample_positions = epi.align_fastq_with_plate_positions(
    input_files,
    adapter_indices = 'dualxt',
    prefix = "mix_"
    )

# Add a column for the genome of each individual
# sample_positions.\
#     insert(3, 'genome', "01_data/03_reference_genome/TAIR10_wholeGenome_withVectors.fasta")
# Write to disk.
sample_positions.\
    to_csv('02_processing/02_align_reads/cross_sample_sheet.csv', index=False)
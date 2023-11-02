"""
Script to calculate methylation in windows across a genome from a cytosine
coverage file.

Returns a CSV file giving chromosome label, start position of the window,
sequence context, number of methylated and unmethylated reads, and total
number of cytosines.
"""

import epiclinestools as epi
import pandas as pd
import argparse

# Parameters
parser = argparse.ArgumentParser()
parser.add_argument(
    '-i', '--input',
    help = """Path to a cytosine2coverage-format file from Bismark. This should have
    no header (this will be added), but seven columns giving chromosome,
    base-pair of each cytosine position on the chromosome, strand (+/-), 
    number of methylated reads, number of unmethylated reads, sequence
    context (CG, CHG, CHH) and tricnucleotide context (for example, for CHG
    methylation this could be CAG, CCG or CTG).""",
    required = True, type=str
    )
parser.add_argument(
    '-o', '--output',
    help = """Path to save the output CSV file giving chromosome label, start
    position of the window, sequence context, number of methylated and
    unmethylated reads, and total number of cytosines.""",
    required = True, type=str
    )
parser.add_argument(
    '-w', '--window',
    help = 'Integer window size',
    required = True, type=int
    )
parser.add_argument(
    '-c', '--chromosome',
    help = 'Integer window size',
    required = False, type=str
    )


args = parser.parse_args()

print("Using epiclinestools verion {}".format(epi.__version__))

# Cytosine coverage file
print("Importing coverage file.")
cx_report = epi.CytosineCoverageFile(args.input)

# Get counts in windows
print("Counting methylated reads in windows")
mC_in_windows = cx_report.methylation_in_windows(
    window_size = args.window,
    chr_labels = [args.chromosome]
    )
# Save to disk
mC_in_windows.to_csv(
    args.output, index=False
)

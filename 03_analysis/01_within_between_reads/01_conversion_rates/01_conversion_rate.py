"""
Calculate methylation rates on each chromosome in a cytosine report file.

Tom Ellis, 28th September 2023
"""

import methlab as ml
import argparse

# Parameters
parser = argparse.ArgumentParser()
parser.add_argument('--input', help="""
Path to the input cytosine report file.
This should be the output of a Bismark cytosine (CX) report, with a row for each cytosine and columns for chromosome, positions, strand, number of methylated reads, total reads, sequence context, and trinucleotide context.
See the help page for `bismark_methylation_extracter` for more, specifically the option `--CX_report`."""
)
parser.add_argument('--output', help="""
File to save the output."""
)
args = parser.parse_args()

cx_report = ml.CytosineCoverageFile(args.input)
conversion = cx_report.conversion_rate(return_proportion = False)
conversion = conversion.loc[conversion['context'] == "total"]
conversion.to_csv(args.output, index = False, float_format='%.3f')
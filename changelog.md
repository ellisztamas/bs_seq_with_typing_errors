# Change log

## Updated conda env and main README

10th September 2024

Updated environment.yml to create a specific environment for this repo.
Added setup.sh to activate this, and added `source setup.sh` to scripts that 
need it.

Updated main readme file to cover these updates, and to cover the NCBI upload.

## Rearrange to use data from NCBI

10th September 2024

I packaged the data and uploaded it to NCBI, and had a general tidy up of the raw data.

- Added script to retrieve raw reads from NCBI
- Changed sample sheets to use NCBI accession names.
- Updated readme files for the data folders for genomes and Illumina raw reads
- Added files with TE lists.
- Corrected read alignment scripts to use the correct path to the bismark script.
- Deleted folder related to the crosses.

## Added figure 4

Scripts and plots to create figure 4.

## Estimate a mean in the presence of typing errors

15th November 2023

- `01_methylation_with_errors.R` defines functions to simulate a binomial
  process and estimate a mean in the presence of errors
- `02_simulate_methylation_over_loci.R` defines a function to simulate N loci
  with a given coverage and error-rate distribution, and calculate mean
  methylation in several ways.
- `03_run_simulations.R` applies the simulation function with various parameters.
- `04_plot_simulations.R` plots the results.


## Attempt to fix read filtering

30th October 2023

Added scripts to get cytosine reports for the bam files with highly methylated 
reads removed.

This didn't work, because reads are not paired. Changing the call to samtools
sort with the -n flag didn't fix it. More work needed.

## Restructure analysis folder
30th October 2023

Rearranged analysis folder to group things by the figure they belong to:

03_analysis
    01_within_reads
        01_conversion_rates
            all reads
            filtered reads
            plot_conversion_rates # needs conversion rates, before and after filterning
        02_error_positions # uses sorted bam files
            python_script - make sam file, get positions, count errors
            col0
            phage
            flies
            plot
            plot_positions.R
            plot_counts.R
        plot_fig1.R
    02_across_chloroplast
        plot windows across chlorplast
        plot annotated features
        plot correlation with GC content
        plot_figure_2.R
    03_simulations
        simulation_code
        plot.R
    04_methylation_status

## Plot figure 1

30th October 2023

Added scripts to calculated conversion rates, and assess non-concversion within
and across reads.

Added scripts to plot the results.

## Filter completely methylated reads

27th October

Scripts to filter dubious reads with 100% methylation.

## Scripts to map reads

Added scripts to prepare genomes and map reads to a genome.

## Initial folder structure

24th October 2023

Set up manuscript folder with a github repo and data subfolder

01_data
    columbia
    drosophila
    cross
    bacteria
    phage

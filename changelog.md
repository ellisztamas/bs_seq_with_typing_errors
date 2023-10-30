# Change log

## Restructure analysis folder

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

20th October 2023

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

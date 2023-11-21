"""
Script to import the TAIR10 annotation file and pull out information methylated
and unmethylated reads in each context for:
1. genes
2. RdDM- and CMT-regulated TEs
3. windows of 1000 base pairs across each chromosome
for the genotyping file on the 30x Col-0 data we ran.
"""

import pandas as pd
import methlab as ml

print("Using methlab verion {}".format(ml.__version__))

# Cytosine coverage file
print("Importing coverage file.")
path = "02_processing/02_align_reads/columbia/output/reports/Col0_05_13X.CX_report.txt.gz"
cx_report = ml.CytosineCoverageFile(path)

# METHYLATION ON GENE BODIES
# annotated genes in tair10
print("Count methylated reads over gene bodies.")
tair10_genes = pd.read_csv(
    "01_data/genomes/TAIR10_GFF3_genes_transposons.gff",
    sep = "\t",
    names = ['seqid', 'source', 'type', 'start', 'end', 'score', 'strand', 'phase', 'attributes']
    )
# Subset genes only
tair10_genes = tair10_genes.loc[ (tair10_genes['type'] == "gene")  ]
# pull gene names and chromosome labels from the attributes column
tair10_genes['seqid'] = tair10_genes['attributes'].str.slice(3,12)
tair10_genes['chr']   = tair10_genes['seqid'].str.slice(2,3)
# Subset autosomes only.
tair10_genes = tair10_genes.loc[
    tair10_genes['chr'].isin(['1', '2', '3','4', '5'])
    ]

# Count methylated reads at each gene and write to disk
gbm = cx_report.methylation_over_features(
    chr = tair10_genes['chr'],
    start = tair10_genes['start'],
    stop = tair10_genes['end'],
    names = tair10_genes['seqid']
)
gbm.to_csv("03_analysis/04_methylation_status/output/mC_genes.csv", index=False)




# CMT2- AND RdDM-REGULATED TRANSPOSABLE ELEMENTS
# Full list of TEs from the TAIR10 annotation
print("Counting methylated reads over transposable elements.")
tair10_TEs = pd.read_csv("01_data/genomes/TAIR10_Transposable_Elements.txt", sep = "\t")
tair10_TEs['chr'] = tair10_TEs['Transposon_Name'].str.slice(2,3)

# Merge with files for TEs regulated by CMT2 and RdDM
CMT2_TEs = tair10_TEs.merge(
    pd.read_csv("01_data/genomes/CMT2_target_TEs.txt", names=['Transposon_Name'])
)
RdDM_TEs = tair10_TEs.merge(
    pd.read_csv("01_data/genomes/RdDM_target_TEs.txt", names=['Transposon_Name'])
)

# Get methylation on each TE.
cmt2_meth = cx_report.methylation_over_features(
    chr = CMT2_TEs['chr'],
    start = CMT2_TEs['Transposon_min_Start'],
    stop = CMT2_TEs['Transposon_max_End'],
    names = CMT2_TEs['Transposon_Name']
)
rddm_meth = cx_report.methylation_over_features(
    chr = RdDM_TEs['chr'],
    start = RdDM_TEs['Transposon_min_Start'],
    stop = RdDM_TEs['Transposon_max_End'],
    names = RdDM_TEs['Transposon_Name']
)
# Write to disk
cmt2_meth.to_csv("03_analysis/04_methylation_status/output/mC_on_cmt2_TEs.csv", index = False)
rddm_meth.to_csv("03_analysis/04_methylation_status/output/mC_on_rddm_TEs.csv", index = False)

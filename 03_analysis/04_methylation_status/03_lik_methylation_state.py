import pandas as pd
import numpy as np
import epiclinestools as epi

# Import counts of converted and unconverted reads across the chloroplasts, on
# genes and on CMT2- and RdDM-targetted TEs.
chloroplast = pd.read_csv(
    "03_analysis/02_across_chloroplast/output/Col0_05_13X.windows.csv"
)
chloroplast['id'] = chloroplast['start'].astype(str)
chloroplast = chloroplast.loc[chloroplast['start'] <= 75000]
genes = pd.read_csv("03_analysis/04_methylation_status/output/mC_genes.csv")
cmt2 = pd.read_csv("03_analysis/04_methylation_status/output/mC_on_cmt2_TEs.csv")
rddm = pd.read_csv("03_analysis/04_methylation_status/output/mC_on_rddm_TEs.csv")

# Estimate shape parameters of the beta distribution
# Estimate the proportion of unconverted reads
chloroplast['n'] = chloroplast['unconverted'] + chloroplast['converted']
chloroplast['theta'] = chloroplast['unconverted'] / chloroplast['n']
# Use the mean and variance across the chloroplast to estimate beta shape parameters
mu = chloroplast['theta'].loc[chloroplast['context'] == "total"].mean()
sigma = chloroplast['theta'].loc[chloroplast['context'] == "total"].var()
ab_errors = epi.estimate_beta_parameters(mu, sigma)

meth_states = pd.concat([
    epi.methylation_state(chloroplast, ab_errors, return_probabilities=True, hard_calls=True).assign(type='Chloroplast'),
    epi.methylation_state(genes, ab_errors, return_probabilities=True, hard_calls=True).assign(type='Genes'),
    epi.methylation_state(rddm, ab_errors, return_probabilities=True, hard_calls=True).assign(type='RdDM TEs'),
    epi.methylation_state(cmt2, ab_errors, return_probabilities=True, hard_calls=True).assign(type='CMT2 TEs')
])

meth_states.to_csv("03_analysis/04_methylation_status/output/meth_states.csv")

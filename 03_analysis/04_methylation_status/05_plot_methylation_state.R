#' Script to plot likelihoods of methylation state across the chloroplast, on
#' genes, CMT2- and RDdM-targetted TEs.
#'
#' This is based on counts of methylated and unmethylated reads calculated with
#' the scripts `01_mC_genes_TEs.py` and `02_submit_mC_genes_TEs.sh`.
#'
#' Tom Ellis, 10th November 2023

library(tidyverse)
library(ggpubr)

source("03_analysis/04_methylation_status/03_lik_methylation_state.R")
source("03_analysis/04_methylation_status/04_estimate_beta_parameters.R")

read_counts <- list(
  # Import read counts from windows across the chloroplast
  Chloroplast = read_csv(
    "03_analysis/02_across_chloroplast/output/Col0_05_13X.windows.csv", col_types = 'ciciii'
  ) %>%
    filter(start <= 75000) %>%
    mutate(id = as.character(start)),
  # Import read counts from genes
  Genes = read_csv(
    "03_analysis/04_methylation_status/output/mC_genes.csv", col_types = 'cciii'
  ),
  # Import read counts from CMT2-targetted TEs
  `CMT2 TEs` = read_csv(
    "03_analysis/04_methylation_status/output/mC_on_cmt2_TEs.csv", col_types = 'cciii'
  ),
  # Import read counts from RdDM-targetted TEs
  `RdDM TEs` = read_csv(
    "03_analysis/04_methylation_status/output/mC_on_rddm_TEs.csv", col_types = 'cciii'
  )
)

meth_states <- vector('list', 4)
names(meth_states) <- names(read_counts)
for(name in names(read_counts)){
  meth_states[[name]] <- lik_methylation_state(
    read_counts[[name]],
    shape1 = beta_params$a, shape2 = beta_params$b,
    return_probabilities = TRUE
  )
  meth_states[[name]]$type <- name
}
meth_states <- do.call('rbind', meth_states)

meth_states <- meth_states %>%
  mutate(
    type = fct_relevel(factor(type), c("Chloroplast", "Genes")),
    state = case_match(
      state,
      "unmethylated" ~ "Unmethylated",
      "mCG" ~ "GBM-like",
      "te_like" ~ "TE-like"
    )
  )

meth_states %>%
  ggplot(aes(x = state, y = ..prop.., group=1)) +
  geom_bar(stat = "count") +
  labs(
    x = "Methylation state",
    y = "Frequency"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  facet_grid(~ type)

ggsave(
  filename = "04_manuscript/figure4.eps",
  device="eps",
  units = "cm", width = 16.9, height = 8
)

# meth_states %>%
#   pivot_longer(unmethylated : te_like, names_to = "State", values_to = "Probability") %>%
#   ggplot(aes( x = State, y = Probability)) +
#   geom_boxplot() +
#   theme_bw() +
#   facet_grid(~type)

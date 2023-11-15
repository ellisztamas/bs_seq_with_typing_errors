#' Script to plot likelihoods of methylation state across the chloroplast, on
#' genes, CMT2- and RDdM-targetted TEs.
#'
#' This is based on counts of methylated and unmethylated reads calculated with
#' the scripts `01_mC_genes_TEs.py` and `02_submit_mC_genes_TEs.sh`.
#'
#' Tom Ellis, 10th November 2023

library(tidyverse)

meth_states <- read_csv("03_analysis/04_methylation_status/output/meth_states.csv") %>%
  rename(state = call) %>%
  filter(coverage >= 10) %>%
  mutate(
    type = fct_relevel(factor(type), c("Chloroplast", "Genes")),
    state = case_match(
      state,
      "unmethylated" ~ "Unmethylated",
      "CG-only" ~ "GBM-like",
      "TE-like" ~ "TE-like"
    ),
    state = fct_relevel(state, "Unmethylated")
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

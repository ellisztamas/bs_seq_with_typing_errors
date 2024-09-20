#' Script to plot likelihoods of methylation state across the chloroplast, on
#' genes, CMT2- and RDdM-targetted TEs.
#'
#' This is based on counts of methylated and unmethylated reads calculated with
#' the scripts `01_mC_genes_TEs.py` and `02_submit_mC_genes_TEs.sh`.
#'
#' Tom Ellis, 10th November 2023

library(tidyverse)

meth_states <- read_csv("03_analysis/04_methylation_status/output/meth_states.csv") %>%
  rename(
    state = call,
    Unmethylated = unmethylated,
    `GBM-like` = `CG-only`
    ) %>%
  mutate(
    type = fct_relevel(factor(type), c("Chloroplast", "Genes"))
    # state = case_match(
    #   state,
    #   "unmethylated" ~ "Unmethylated",
    #   "CG-only" ~ "GBM-like",
    #   "TE-like" ~ "TE-like"
    # ),
    # state = fct_relevel(state, "Unmethylated")
  )

meth_states %>%
  pivot_longer(Unmethylated : `TE-like`) %>%
  group_by(type, name) %>%
  summarise(
    mean = mean(value, na.rm = TRUE)
  ) %>%
  mutate(
    name = as.factor(name),
    name = fct_relevel(name, "Unmethylated")
    ) %>%
  ggplot(aes(x = name, y = mean)) +
  geom_col() +
  lims(y = c(0,1)) +
  labs(
    x = "Methylation state",
    y = "Probability"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  facet_grid(~ type)

ggsave(
  filename = "04_manuscript/figure4.eps",
  device="eps",
  units = "cm", width = 13.2, height = 8
)

meth_states %>%
  group_by(type, state) %>%
  summarise(
    n = n()
  ) %>%
  filter(!is.na(state)) %>%
  group_by(type ) %>%
  summarise(
    state,
    mean = n / sum(n)
  )

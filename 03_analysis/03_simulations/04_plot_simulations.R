library('tidyverse')
library("ggpubr")

sims <- read_csv(
  '03_analysis/03_simulations/simulations.csv'
  ) %>%
  select(-integration) %>%
  filter(nloci <= 1e2) %>%
  mutate(
    nloci = ifelse(nloci == 1, paste0(nloci, " locus"), paste0(nloci, " loci"))
  ) %>%
  pivot_longer(no_errors : lambda_mean) %>%
  mutate(name = fct_relevel(name, rev))

plot_sim_distributions <- sims %>%
  ggplot(
    aes(x = factor(coverage), y = value, colour=name)) +
  geom_boxplot() +
  labs(
    x = "Sequencing coverage",
    y = "Estimated mean"
  ) +
  scale_colour_discrete(
    labels = c(
      "No errors",
      "Error rate is known",
      "Error rate is estimated"
    )
  ) +
  theme_bw() +
  theme(
    legend.title = element_blank()
  ) +
  facet_grid(~factor(nloci))

pd<- position_dodge(0)

plot_sim_deviation <-sims %>%
  mutate(deviation = abs(value - real_p)) %>%
  group_by(coverage, nloci, name) %>%
  summarise(
    deviation = mean(deviation),
    lower = quantile(deviation, 0.02),
    upper = quantile(deviation, 0.98),
  ) %>%
  ggplot(
    aes(x = factor(coverage), y = deviation, colour = name, group=name)) +
  geom_line(position = pd) +
  # geom_errorbar(aes(ymin = lower, ymax = upper), width=0, position = pd) +
  geom_point(position = pd) +
  labs(
    x = "Sequencing coverage",
    y = "Average deviation"
  ) +
  scale_colour_discrete(
    labels = c(
      "No errors",
      "Error rate is known",
      "Error rate is estimated"
    )
  ) +
  theme_bw() +
  theme(
    legend.title = element_blank()
  ) +
  facet_grid(~factor(nloci))


plot_bias <- sims %>%
  mutate(bias = (value - real_p)) %>%
  group_by(coverage, nloci, name) %>%
  summarise(
    bias = mean(bias),
    lower = quantile(bias, 0.02),
    upper = quantile(bias, 0.98),
  ) %>%
  ggplot(
    aes(x = factor(coverage), y = bias, colour = name, group=name)) +
  geom_line(position = pd) +
  # geom_errorbar(aes(ymin = lower, ymax = upper), width=0, position = pd) +
  geom_point(position = pd) +
  labs(
    x = "Sequencing coverage",
    y = "Average bias"
  ) +
  scale_colour_discrete(
    labels = c(
      "No errors",
      "Error rate is known",
      "Error rate is estimated"
    )
  ) +
  theme_bw() +
  theme(
    legend.title = element_blank()
  ) +
  facet_grid(~factor(nloci))

ggarrange(
  plot_sim_distributions, plot_sim_deviation, plot_bias,
  nrow=3,
  labels="AUTO",
  common.legend = TRUE,
  legend = "bottom"
  )

ggsave(
  filename = "04_manuscript/figure3.eps",
  device =cairo_ps,
  units = "cm", width = 13.2, height = 16
)

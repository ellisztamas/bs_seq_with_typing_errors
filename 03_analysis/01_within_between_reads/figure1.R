source("03_analysis/01_within_between_reads/01_conversion_rates/03_plot_non-conversion_rates.R")
source("03_analysis/01_within_between_reads/02_errors_on_reads/06_plot_error_counts.R")
source("03_analysis/01_within_between_reads/02_errors_on_reads/07_plot_error_positions.R")

ggarrange(
  plot_nonconversion,
  plot_error_counts,
  plot_error_positions,
  nrow=3,
  labels = 'AUTO'
)

ggsave(
  file = "04_manuscript/figure1.eps",
  device = "eps",
  units = "cm", width = 13.2, height = 16
  )

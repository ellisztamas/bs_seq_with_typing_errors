# Plot cytosine non-conversion across the chloroplast for Arabidopsis samples.

library(ggpubr)
library(tidyverse)

# Function to import each window file.
# Supply a vector of paths.
import_windows <- function(paths){
  mC_in_windows <- lapply(
    paths, read_csv, col_types = 'ciciii'
  )
  # Unique ID for each window
  for(i in 1:length(mC_in_windows)){
    # mC_in_windows[[i]]$name <- str_extract(paths, "mix_[A-H][0-9]+")[i]
    mC_in_windows[[i]]$name <- str_extract(paths, "Col0_[01][50]_1[35]X")[i]
    mC_in_windows[[i]]$id <- paste(mC_in_windows[[i]]$chr, mC_in_windows[[i]]$start, sep = "_")
  }
  mC_in_windows <- do.call('rbind', mC_in_windows) %>%
    mutate(
      n = unconverted + converted,
      theta = meth /n
    ) %>%
    filter(
      chr == "chloroplast", start <=75000, context == "total", n > 0)

  return(mC_in_windows)
}
# Import data files
col0 <- import_windows(Sys.glob("03_analysis/02_across_chloroplast/output/Col0*"))

# Plot non-conversion across windows.
plot_col0_windows <- col0 %>%
  ggplot( aes(x = start, y = theta, colour = name, group=name )) +
  geom_line() +
  labs(
    x = "Window position",
    y = "Non-conversion"
  ) +
  theme_bw() +
  theme(legend.position="none")

# Plot non-conversion vs coverage
plot_coverage <- col0 %>%
  ggplot(aes(x = n/150, y = theta, colour=name)) +
  geom_point(size=0.5) +
  labs(
    x = 'Coverage',
    y = 'Non-conversion'
  ) +
  theme_bw() +
  theme(legend.position="none")
# Plot non-conversion vs GC content
plot_GC_content <- col0 %>%
  ggplot(aes(x = ncytosines/150, y = theta, colour=name)) +
  geom_point(size=0.5) +
  labs(
    x = "GC content",
    y = "Non-conversion"
  ) +
  theme_bw() +
  theme(legend.position="none")

# Combine plots
ggarrange(
  plot_col0_windows,
  ggarrange(
    plot_coverage, plot_GC_content,
    ncol = 2, labels = c("B", "C")
  ),
  nrow=2,
  labels = c("A", "")
)

ggsave(
  filename = "04_manuscript/figure2.eps",
  device = "eps",
  units = "cm", height = 10, width= 13
)

# cor( col0$n, col0$theta, method = 's')
#
# for( sample in unique(col0$name)){
#   print(
#     cor( col0$n[col0$name == sample], col0$theta[col0$name == sample], method = 's')
#   )
# }
# for( sample in unique(col0$name)){
#   print(
#     cor( col0$ncytosines[col0$name == sample], col0$theta[col0$name == sample], method = 's')
#   )
# }
#
# for( sample1 in unique(col0$name)){
#   for( sample2 in unique(col0$name)){
#     print(
#       cor( col0$theta[col0$name == sample1], col0$theta[col0$name == sample2], method = 's')
#     )
#   }
# }
#
#
# Compare variation between windows to binimal draws between windows
# tibble(
  # id = col0$name,
#   obs = col0$theta,
#   sim = sapply(col0$n, rbinom, n=1, prob = mean(col0$theta) ) / col0$n
# ) %>%
#   pivot_longer(obs:sim) %>%
#   group_by(id, name) %>%
#   summarise(
#     sd = sd(value)
#   )
# # Plot this as a box plot
# tibble(
#     id = col0$name,
#     obs = col0$theta,
#     sim = sapply(col0$n, rbinom, n=1, prob = mean(col0$theta) ) / col0$n
#   ) %>%
#   pivot_longer(obs:sim) %>%
#   ggplot(aes( x = name, y = value, colour= id)) +
#   geom_boxplot() +
#   theme_bw() +
#   theme(legend.position="none")

  # ggplot(aes( x= value, colour=id, linetype=name)) +
  # geom_freqpoly()


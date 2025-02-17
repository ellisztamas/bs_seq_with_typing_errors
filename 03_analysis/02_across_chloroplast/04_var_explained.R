#' Calculate the proportion of variance explained by the density of CG,
#' CHG and CHH sites in each window of the A. thaliana chloroplast

library(tidyverse)
library(r2glmm)

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
      theta = unconverted /n
    ) %>%
    filter(
      chr == "chloroplast", start <=75000, n > 0)

  return(mC_in_windows)
}
# Import data files
col0 <- import_windows(Sys.glob("03_analysis/02_across_chloroplast/output/Col0*windows.csv"))

# Dataframe giving overall (logit) error rate against density of each
# sequence context.
d <- col0 %>%
  select(start, name, context, ncytosines) %>%
  filter(context != 'total') %>%
  pivot_wider(names_from = context, values_from = ncytosines) %>%
  mutate(
    CG = ifelse( is.na(CG),  0, CG),
    CHG = ifelse(is.na(CHG), 0, CHG),
    CHH = ifelse(is.na(CHH), 0, CHH)
  ) %>%
  inner_join(
    col0 %>% filter(context == 'total') %>% select(start, name, theta),
    by = c('start', 'name')
  ) %>%
  mutate(
    logit_theta = log(theta / (1-theta))
  )

# Linear model of logit error rate
m1 <- lme4::lmer(logit_theta ~ CG + CHG + CHH + (1|name), data = d)
# Variance explained by fixed effects from the r2glmm package.
r2beta(m1, method='nsj')

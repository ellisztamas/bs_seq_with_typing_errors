#' Estimate the a and b shape parameters of a beta distibution describing
#' variation in non-conversion error rates across a chlorplast.
#'
#' Tom Ellis, 10th November, 2023

library(tidyverse)

#' Estimate shape parameters of the beta distribution of error rates from the chloroplast.
#' Pass the mean and variance of means across windows.
#' Returns a list of floats with elements a and b.
estimate_beta_params <- function(mu, sigma){
  x <- ((mu * (1-mu)) / sigma) -1
  a <-  mu * x
  b <- (1-mu) * x

  list(
    a = a,
    b = b
  )
}

# Import the data file, get the mean and variance between windows, then apply
# the function.
beta_mean_variance <- read_csv(
  "03_analysis/02_across_chloroplast/output/Col0_05_13X.windows.csv", col_types = 'ciciii'
) %>%
  filter(start <= 75000) %>%
  mutate(
    theta = meth / (unconverted + converted)
  ) %>%
  filter(
    context == 'total'
  ) %>%
  summarise(
    mean = mean(theta),
    var  = var(theta)
  ) %>%
  as.vector() %>%
  unlist()

beta_params <- estimate_beta_params(beta_mean_variance[1], beta_mean_variance[2])

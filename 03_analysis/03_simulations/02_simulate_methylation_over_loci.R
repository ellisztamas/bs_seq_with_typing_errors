source("03_analysis/03_simulations/01_methylation_with_errors.R")

#' Compare methylation estimates across simulated loci
#'
#' This simulates unconverted reads from a binomial process for one or more loci
#' with a given number of cytosines.
#' Each locus has its own non-conversion error rate drawn from a beta distribution.
#' Observed counts are then summed over loci, and true methylation level is
#' estimates three ways: (1) using the best global estimate of error rates, (2)
#' using the average error rate across loci, which is known here but would not
#' be known in practice, and (3) by integrating over the beta distribution of
#' errors. In addiition, the function also simulates data in the same way but
#' with no non-conversion errors.
#'
#' @param nloci Integer number of loci to sum over
#' @param ncytosines Integer number of cytosines per locus
#' @param coverage Average number of reads mapping to each cytosine.
#' @param real_p True probability that any read is methylated.
#' @param shape1,shape2 Shape parameters of the beta distribution of errors
#' across loci.
#'
#' @return Vector giving input parameters and estimates of methylation level.
#'
simulate_methylation_over_loci <- function(nloci, ncytosines, coverage, real_p, shape1, shape2){
  lambda1 <- rbeta(nloci, shape1, shape2)

  clean_data <- rbinom(
    n = nloci,
    size = ncytosines * coverage,
    prob = real_p
  )

  unconverted <- rbinom_with_errors(
    n = nloci,
    size = ncytosines * coverage,
    prob = real_p,
    lambda1 = lambda1,
    lambda2 = 0
  )

  estimates <- c(
    # Probability of success in data with zero errors.
    no_errors = sum(clean_data) / (ncytosines * coverage * nloci),
    # Estimate using the mean of the beta distribution
    beta_mean = binomial_mean_with_errors(
      x = sum(unconverted),
      size = ncytosines * coverage * nloci,
      lambda1 = shape1 / (shape1 + shape2),
      lambda2 = 0
    ),
    # Estimate including uncertainty in errors
    integration = binomial_mean_with_uncertainty(
      x = sum(unconverted),
      size = ncytosines * coverage * nloci,
      shape1 = shape1,
      shape2 = shape2
    ),
    # Estimate using the mean error between loci.
    lambda_mean = binomial_mean_with_errors(
      x = sum(unconverted),
      size = ncytosines * coverage * nloci,
      lambda1 = mean(lambda1),
      lambda2 = 0
    )
  )

  params = c(
    nloci = nloci,
    ncytosines = ncytosines,
    coverage  = coverage,
    real_p = real_p,
    shape1 = shape1,
    shape2 = shape2
    )


  return (
    c(params, estimates)
  )
}

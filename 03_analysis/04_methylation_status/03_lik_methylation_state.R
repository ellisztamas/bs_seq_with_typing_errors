#' Support for methylation status
#'
#' `call_methylation_state` calls whether that a region of DNA is unmethylated,
#' methylated in CG only, or methylated in CG, CHG and CHH contexts (TE-like
#' methylation).
#'
#' This compares the evidence that observed methylated read counts patterns were
#' generated from:
# \enumerate{
#'   \item the expected distribution of non-conversion errors, modelled as a
#'   beta distribution
#'   \item an additional process, modelled as the cumulative distribution of the
#'   same beta distribution.
#' }#'
#' One way to estimate shape parameters for the beta distribution is to fit a
#' beta distribution to non-conversion rates over windows of known
#' unmethylated control DNA, like a chloroplast.
#'
#' The function then estimates likelihoods that the region is either methylated
#' or not in each sequence context, and uses these to call methylation status.
#' To be conservative, this is done by intially assuming everything to be
#' unmethylated.
#' CG-methaylated windows are called if the log likelihood of mCG is >3 than
#' that the region is unmethylated.
#' TE-like methylation is called ifthe log likelihood of TE- methylation is >3
#' than the that the region is CG-methylated.
#'
#' Note that when there is no coverage at both log likelihoods are NA.
#' As a workaround, these are set to 0 so ratios can be calculated.
#' This is not ideal, but shouldn't bias inference because we are really
#' comparing support between two models.
#' When both are equal we can't tell them apart.
#' In reality this usually happens when coverage is very low, and it would be
#' sensible to set a lower bound on coverage.
#'
#' In addition, note that when theta is exactly one or zero, binomial
#' likelihoods cannot be calculated. In these cases, the function offsets theta
#' by 1e-12 to ensure stability, with a slight cost to accuracy.
#'
#' @param read_counts Dataframe of read counts over one or more feaures with
#' columns `id` (feature name), `context` (sequence context: `CG`, `CHG`, `CHH`,
#' `total`), `meth` (integer counts of methylated reads mapping in each context,
#' ), `unmethylated` (integer counts of un methylated reads mapping in each
#' context).
#' @param shape1 Float giving the alpha parameter of the beta distribution of
#' the conversion-rate-error distribution. This corresponds to the `shape1`
#' arguments to `dbeta` (see `?dbeta`)
#' @param lambda2 Float giving the beta parameter of the beta distribution of
#' the conversion-rate-error distribution. This corresponds to the `shape2`
#' arguments to `dbeta` (see `?dbeta`)
#' @param return_probabilities If TRUE, log likelihoods are normalised to sum to
#' one.
#'
#' @return Dataframe giving feature ID, coverage, log likelihoods that each
#' fearture is unmethylated, CG methylated or TE methylated, and a categorical
#' call on methylation status.
#'
#' @seealso dbeta, pbeta
#'
#' @author  Tom Ellis
lik_methylation_state <- function(read_counts, shape1, shape2, return_probabilities=FALSE){

  # Total coverage
  read_counts$n <- read_counts$unconverted + read_counts$converted

  # Mean methylation, without correcting for errors
  read_counts$theta <- read_counts$unconverted / read_counts$n
  # When theta is exactly zero or one the likelihood is undefined, so set it to
  # something very close to those numbers.
  read_counts$theta[read_counts$theta == 0] <- 1e-12
  read_counts$theta[read_counts$theta == 1] <- 1-1e-12

  # Probability of getting the data given observed theta
  ll_binom <- dbinom(read_counts$unconverted, size = read_counts$n, prob = read_counts$theta, log = TRUE)
  # Probability of theta from conversion errors
  log_prior_null        <- dbeta(read_counts$theta, shape1, shape2, log=TRUE)
  read_counts$ll_zero  <- ll_binom + log_prior_null
  # Probability that theta is more than can be accounted for by conversion errors
  log_prior_alternative <- pbeta(read_counts$theta, shape1, shape2, log=TRUE)
  read_counts$ll_theta <- ll_binom + log_prior_alternative

  # If methylation is 100%, change log likelihood from NaN to 0
  # read_counts$ll_theta = ifelse(read_counts$theta == 1, 0, read_counts$ll_theta)
  # If there is no coverage at all, return likelihoods of zero
  read_counts$ll_theta = ifelse(read_counts$n == 0, 0, read_counts$ll_theta)
  read_counts$ll_zero  = ifelse(read_counts$n == 0, 0, read_counts$ll_zero)

  # Log likelihoods that each feature is unmethylated
  ll_unmethylated = read_counts$ll_zero[ read_counts$context == "CG" ] +
    read_counts$ll_zero[ read_counts$context == "CHG" ] +
    read_counts$ll_zero[ read_counts$context == "CHH" ]
  # Log likelihoods that each feature is CG methylated
  ll_CG = read_counts$ll_theta[ read_counts$context == "CG" ] +
    read_counts$ll_zero[ read_counts$context == "CHG" ] +
    read_counts$ll_zero[ read_counts$context == "CHH" ]
  # Log likelihoods that each feature is TE-like methylated
  ll_te_like = read_counts$ll_theta[ read_counts$context == "CG" ] +
    read_counts$ll_theta[ read_counts$context == "CHG" ] +
    read_counts$ll_theta[ read_counts$context == "CHH" ]

  # Return a dataframe giving feature ID, coverage, and loglikelihoods
  output <- data.frame(
    id = unique(read_counts$id),
    n  = read_counts$n[read_counts$context == "total"],
    unmethylated = ll_unmethylated,
    mCG = ll_CG ,
    te_like = ll_te_like
  )
  # Make a call on methylation status at each feature.
  output$state <- ifelse(output$n > 0, "unmethylated", NA)
  output$state <- ifelse(
    (output$mCG - output$unmethylated) > 0, "mCG", output$state
  )
  output$state <- ifelse(
    (output$te_like - output$mCG) > 0, "te_like", output$state
  )

  # Normalise log likelihoods values to sum to one within rows.
  if(return_probabilities){
    aic_sum <- apply(output[, c('unmethylated', 'mCG', 'te_like')], 1, logsumexp)
    output$unmethylated <- exp(output$unmethylated - aic_sum)
    output$mCG <- exp(output$mCG - aic_sum)
    output$te_like <- exp(output$te_like - aic_sum)
  }

  output
}

# Sum over a vector of log values
logsumexp <- function(x){
  max(x) + log(sum(exp(x - max(x))))
}


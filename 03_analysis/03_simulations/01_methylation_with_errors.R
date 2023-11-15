#' Mean methylation with errors
#'
#' Calculate the mean of a binomial process correcting for false positive and
#' false negative errors in observed successes.
#'
#' For a sample of \eqn{n} binomial trials we observe \eqn{y} 'successes' and
#' \eqn{n-y} 'failures'.
#' However, each observed 'success' may be truly a failure with probability
#' \eqn{lambda_1}, and each apparent 'failure' is truly a success with
#' probability \eqn{lambda_2}.
#' Summarising \eqn{p=y/n}, the best estimate of true methylation level is then
#' \deqn{
#'    \hat{\theta} = \frac{lambda_1 - p}{lambda_1 + lambda_2 -1}
#' }
#'
#' @param x Observed number of successes
#' @param size Number of trials.
#' @param lambda1 Probability that a true failure is observed to be a success.
#' @param lambda2 Probability that a true success is observed to be a failure.
#'
#' @return Point estimate of the true success rate, corrected for errors.
#' If the estimate falls beyond zero or one, these will be corrected.
#'
#' @author Tom Ellis
binomial_mean_with_errors <- function(x, size, lambda1, lambda2){
  p <- x/size
  theta <- (lambda1 - p) / (lambda1 + lambda2 -1)

  # If estimates fall outside [0,1], set them articifically to the boundaries.
  theta[theta<0] <- 0
  theta[theta>1] <- 1

  return(theta)
}

#' Draws from a binomial distribution with errors
#'
#' Random number generation for a binomial distribution with errors.
#'
#' #' For a sample of \eqn{n} binomial trials we observe \eqn{y} 'successes' and
#' \eqn{n-y} 'failures'.
#' However, each observed 'success' may be truly a failure with probability
#' \eqn{lambda_1}, and each apparent 'failure' is truly a success with
#' probability \eqn{lambda_2}.
#'
#' @param n Number of samples to draw.
#' @param size Number of binomial trials per sample.
#' @param prob Vector of true probabilities of success.
#' @param lambda1 Probability that a true failure is observed to be a success.
#' @param lambda2 Probability that a true success is observed to be a failure.
#'
#' @return Vector of counts of apparent successes, including true and false
#' successes.
#' @author Tom Ellis
rbinom_with_errors <- function(n, size, prob, lambda1, lambda2){
  true_successes <- prob * (1-lambda2)
  false_successes <- (1-prob) * lambda1

  rbinom(n, size, prob = true_successes + false_successes)
}

#' Binomial mean with uncertainty in errors
#'
#' Estimate the posterior-mean probability of successes of a binomial process in
#' the presence of false positive errors, when these errors are drawn from a
#' beta distribution.
#'
#' For a sample of \eqn{n} binomial trials we observe \eqn{y} 'successes' and
#' \eqn{n-y} 'failures'.
#' However, each observed 'success' may be truly a failure with probability
#' \eqn{lambda}.
#' In addition, there may be uncertainty about the value of the error rate, but
#' believe it to be drawn from a beta distribution.
#' We can estimate the true success rate by integrating out plausible values of
#' error rates by taking the expected value
#' \deqn{
#'     \hat{\theta} =
#'     \int_0^1
#'     \frac{\lambda - p} {\lambda - 1}
#'     \Pr(\theta | \lambda) \,d\lambda
#'     }
#' where \eqn{\Pr(\theta | \lambda)} is the probability density of \eqn{\lambda}
#' from the beta distribution.
#'
#' This function approximates this integral by performing grid interpolation
#' over equally spaced values of \eqn{\lambda}
#' To optimise computation, the grid is restricted to the region between zero
#' and one corresponding to the 99% high-density region of the beta distribution.
#'
#' @param x Observed number of successes
#' @param size Number of trials.
#' @param shape1,shape2 Shape parameters of the beta distribution.
#' @param npoints Number of points used to approximate the beta distribution.
#'
#' @return Vector of estimated true probabilities of success.
#' @author Tom Ellis
binomial_mean_with_uncertainty <- function(x, size, shape1, shape2, npoints=1000){

  # Vector of error rates to evaluate
  # These are evenly spaced within the 99% probability density interval of the beta distribution.
  lambda_vals <- seq(
    qbeta(0.005, shape1, shape2),
    qbeta(0.995, shape1, shape2),
    length.out = npoints
  )
  # Prior probability of each lambda values
  lambda_probs <- dbeta(lambda_vals, shape1, shape2)
  lambda_probs <- lambda_probs / sum(lambda_probs)
  # lambda_probs <- rep(1, 100)
  # Replicate lambda values int o
  lambda_matrix <- matrix(
    rep(lambda_vals, length(x)),
    nrow = length(x),
    byrow = TRUE
  )

  # Proportion of observed successes.
  p <- x/size
  # Matrix of true methylation level for each value of lambda
  # Dimensions: length(x) * length(lambda_vals)
  theta_matrix <- (lambda_matrix - p) / (lambda_matrix -1)
  theta_matrix[theta_matrix < 0] <-0

  # Sum over the lambda axis to get the expected values for theta
  rowSums(theta_matrix * lambda_probs)
}


source("03_analysis/03_simulations/02_simulate_methylation_over_loci.R")

nloci <- 10^(0:5)
coverage <- c(1,2,4,8,16,32)
shape1 <- 17
shape2 <- 220
nreps <- 200

nsims <- length(nloci) * length(coverage) * nreps

sims <- matrix(NA, nrow = nsims, ncol=10)

counter <- 1
for(n in nloci){
  for(cov in coverage){
    for(r in 1:nreps){
      sims[counter,]  <- simulate_methylation_over_loci(
        nloci <- n,
        ncytosines = 200,
        coverage   = cov,
        real_p     = 0.15,
        shape1 = shape1,
        shape2 = shape2
      )

      counter <- counter + 1
    }
  }
}


sims <- as.data.frame(sims)
names(sims) <- c(
  'nloci', 'ncytosines', 'coverage', 'real_p', 'shape1', 'shape2',
  'no_errors', 'beta_mean', 'integration', 'lambda_mean'
  )

write.csv(sims, file = "03_analysis/03_simulations/simulations.csv", row.names = FALSE)

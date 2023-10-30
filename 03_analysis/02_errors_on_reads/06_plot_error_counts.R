library(tidyverse)
library(ggpubr)

# Function to import and format the data sets
import_error_counts <- function(filename){
  suppressMessages(
    d <- read_csv(filename, show_col_types = FALSE)
  )
  if( any(colnames(d) != c('...1', 'OT','CTOT','CTOB','OB')) ){
    stop(paste("Colnames for file\n", filename, "\n are not as expected."))
  }

  d <- d %>%
    rename(quantile = `...1`) %>%
    mutate(
      filename = basename(filename),
      OT   = OT   / sum(OT),
      CTOT = CTOT / sum(CTOT),
      CTOB = CTOB / sum(CTOB),
      OB   = OB   / sum(OB)
    ) %>%
    pivot_longer(OT:OB, names_to = 'flag', values_to = 'count') %>%
    group_by(quantile, filename) %>%
    summarise(
      count = mean (count),
      .groups = "drop_last"
    ) %>%
    mutate(
      Transposase = ifelse(str_extract(filename, "_[01][50]_") == "_05_", "0.5", "1.0"),
      `PCR cycles` = ifelse(str_extract(filename, "1[35]X") == "13X", "13", "15")
    )
  d
}


# Data from Columbia
col0_files <- Sys.glob("03_analysis/02_errors_on_reads/output/Col0*counts.csv")
col0 <- lapply(col0_files, import_error_counts) %>%
  do.call(what = 'rbind') %>%
  mutate(filename = str_extract(filename, "Col0_[0-5]{2}_1[35]X"))
# Data from Drosophila
fly_files <- Sys.glob("03_analysis/02_errors_on_reads/output/Fly*counts.csv")
flies <- lapply(fly_files, import_error_counts) %>%
  do.call(what = 'rbind') %>%
  mutate(filename = str_extract(filename, "Fly._[0-5]{2}_1[35]X"))
# Data on Lambda phage DNA included in each sample as a control.
lambda_files <- Sys.glob("03_analysis/02_errors_on_reads/output/lambda*counts.csv")
lambda <- lapply(lambda_files, import_error_counts) %>%
  do.call(what = 'rbind')


list_error_counts <- list(
  columbia = col0 %>%
    filter(quantile > 0, quantile < 101) %>%
    ggplot(aes( x=quantile, y = count, colour=Transposase, linetype=`PCR cycles`)) +
    geom_line() +
    labs(
      title = "Arabidopsis",
      x = "",
      y = "Prop. reads"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(size=10)
      ),

  drosophila = flies %>%
    filter(quantile > 0, quantile < 101) %>%
    ggplot(aes( x=quantile, y = count, colour=Transposase, linetype=`PCR cycles`)) +
    geom_line() +
    labs(
      title = "Drosophila",
      x = "% unconverted",
      y = "Prop. reads"
    ) +
    theme_bw() +
    theme(
      axis.title.y = element_blank(),
      plot.title = element_text(size=10)
      ),


  lambda = lambda %>%
    filter(quantile > 0, quantile < 101) %>%
    ggplot(aes( x=quantile, y = count, colour=Transposase, linetype=`PCR cycles`)) +
    geom_line() +
    labs(
      title = "Lambda phage",
      x = "",
      y = "Prop. reads"
    ) +
    theme_bw() +
    theme(
      axis.title.y = element_blank(),
      plot.title = element_text(size=10))
)

plot_error_counts <- ggarrange(
  plotlist = list_error_counts,
  ncol=3,
  legend = 'right',
  common.legend = TRUE
  )

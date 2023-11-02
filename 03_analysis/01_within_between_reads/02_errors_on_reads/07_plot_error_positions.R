library(tidyverse)
library(ggpubr)


# Function to import and format the data sets
import_error_positions <- function(filename){
  suppressMessages(
    d <- read_csv(filename, show_col_types = FALSE)
  )
  if( any(colnames(d) != c('...1', 'OT','CTOT','CTOB','OB')) ){
    stop(paste("Colnames for file\n", filename, "\n are not as expected."))
  }

  d <- d %>%
    rename(pos = `...1`) %>%
    mutate(
      filename = basename(filename),
      OB = OB[nrow(.):1],
      CTOB = CTOB[nrow(.):1]
    ) %>%
    pivot_longer(OT:OB, names_to = 'Strand', values_to = 'count')
  d
}



# Data from Columbia
col0_files <- Sys.glob("03_analysis/01_within_between_reads/02_errors_on_reads/output/Col0*positions.csv")
col0 <- lapply(col0_files, import_error_positions) %>%
  do.call(what = 'rbind') %>%
  mutate(filename = str_extract(filename, "Col0_[0-5]{2}_1[35]X"))
# Data from Drosophila
fly_files <- Sys.glob("03_analysis/01_within_between_reads/02_errors_on_reads/output/Fly*positions.csv")
flies <- lapply(fly_files, import_error_positions) %>%
  do.call(what = 'rbind') %>%
  mutate(filename = str_extract(filename, "Fly._[0-5]{2}_1[35]X"))
# Data on Lambda phage DNA included in each sample as a control.
lambda_files <- Sys.glob("03_analysis/01_within_between_reads/02_errors_on_reads/output/lambda_*positions.csv")
lambda <- lapply(lambda_files, import_error_positions) %>%
  do.call(what = 'rbind')

list_error_positions <- list(
  columbia = col0 %>%
    group_by(pos, Strand) %>%
    summarise(
      count = mean(count)
    ) %>%
    ggplot(aes( x=pos, y = count, colour=Strand)) +
    geom_line() +
    labs(
      title = "Arabidopsis",
      x = "",
      y = "Prob. non-conversion"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(size=10)
    ),

  drosophila = flies %>%
    group_by(pos, Strand) %>%
    summarise(
      count = mean(count)
    ) %>%
    ggplot(aes( x=pos, y = count, colour=Strand)) +
    geom_line() +
    labs(
      title = "Drosophila",
      x = "Position",
      y = "Prob. non-conversion"
    ) +
    theme_bw() +
    theme(
      axis.title.y = element_blank(),
      plot.title = element_text(size=10)
    ),

  lambda = lambda %>%
    group_by(pos, Strand) %>%
    summarise(
      count = mean(count)
    ) %>%
    ggplot(aes( x=pos, y = count, colour=Strand)) +
    geom_line() +
    labs(
      title = "Lambda phage",
      x = "",
      y = "Prob. non-conversion"
    ) +
    theme_bw() +
    theme(
      axis.title.y = element_blank(),
      plot.title = element_text(size=10)
    )
)

plot_error_positions <- ggarrange(
  plotlist = list_error_positions,
  ncol=3,
  legend = 'right',
  common.legend = TRUE
)

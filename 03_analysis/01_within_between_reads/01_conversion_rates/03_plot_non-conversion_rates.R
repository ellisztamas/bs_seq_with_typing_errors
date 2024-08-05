library('tidyverse')

# Non-conversion rates in Columbia
col0_files <- Sys.glob('03_analysis/01_within_between_reads/01_conversion_rates/output/Col0*')
col0 <- lapply(col0_files, read_csv, col_types = "cciii") %>%
  do.call(what = 'rbind') %>%
  filter(
    id == "chloroplast"
  ) %>%
  mutate(
    organism = "Arabidopsis",
    filename = str_extract(basename(col0_files), "Col0_[0-5]{2}_1[35]X"),
    meth = unconverted / (unconverted + converted)
  ) %>%
  select(organism, filename, meth)

# Non-conversion rates on drosophila samples
fly_files <- Sys.glob('03_analysis/01_within_between_reads/01_conversion_rates/output/Fly*')
flies <- vector('list', length = length(fly_files))
for( i in 1:length(fly_files) ){
  flies[[i]] <- read_csv(fly_files[[i]], col_types = 'cciii') %>%
    filter(
      !grepl("NZ_", id), !grepl("NC_021181.2", id), !grepl("pUC19", id), !grepl("Lambda", id)
    ) %>%
    mutate(
      organism = "Drosophila",
      filename = str_extract(basename(fly_files[i]), "Fly._[0-5]{2}_1[35]X")
      )
}
flies <- do.call('rbind', flies)
flies <- flies %>%
  group_by(organism, filename) %>%
  summarise(
    meth = sum(unconverted, na.rm=TRUE) / sum(unconverted + converted, na.rm = TRUE),
    .groups = "drop_last"
  )

# Non-conversion rates for the Lambda phage
lambda_files <- Sys.glob('03_analysis/01_within_between_reads/01_conversion_rates/output/*csv')
lambda <- lapply(lambda_files, read_csv, col_types = "cciii") %>%
  do.call(what = 'rbind') %>%
  filter(
    id == "Lambda"
  ) %>%
  mutate(
    organism = "Lambda phage",
    filename = paste0(
      'lambda_', str_extract(basename(lambda_files), ".{3,4}_[0-5]{2}_1[35]X")
      ),
    meth = unconverted / (unconverted + converted)
  ) %>%
  select(organism, filename, meth)

# Combine and plot
plot_nonconversion <- rbind(col0, flies, lambda) %>%
  mutate(
    Transposase  = ifelse(str_extract(filename, "_[01][50]_") == "_05_", "0.5", "1.0"),
    `PCR cycles` = ifelse(str_extract(filename, "1[35]X") == "13X", "13", "15")
  ) %>%
  ggplot(aes( x=Transposase, y = meth, colour = `PCR cycles`)) +
  geom_point() +
  labs(
    x = "Relative concentration of transposase to DNA",
    y = "Non-conversion"
  ) +
  facet_grid(~organism) +
  theme_bw() +
  theme(
    legend.position = "right"
  )


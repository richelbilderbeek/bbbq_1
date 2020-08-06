# Creates figure 'fig_ic50_distribution.png'
# that shows the IC50 distributions per haplotype per target
# for all haplotypes and targets
#
# Usage:
#
#  Rscript create_figure_range.R
#
#
#
#
#
library(dplyr)
library(ggplot2)
library(testthat)

# The number of IC50s that are sampled
n_ic50s <- 10
message("'n_ic50s': '", n_ic50s, "'")

haplotypes_filename <- "haplotypes.csv"
message("'haplotypes_filename': '", haplotypes_filename, "'")
testthat::expect_true(file.exists(haplotypes_filename))
t_haplotypes <- readr::read_csv(haplotypes_filename)

targets <- c("covid", "myco", "human")

tibbles <- list()

i <- 1
for (target in targets) {
  for (haplotype_id in t_haplotypes$haplotype_id) {
    filename <- paste0(target, "_", haplotype_id, "_ic50s.csv")
    if (!file.exists(filename)) next()

    haplotype <- t_haplotypes$haplotype[t_haplotypes$haplotype_id == haplotype_id]

    t <- readr::read_csv(
      filename,
      col_types = readr::cols(
        ic50 = readr::col_double(),
        .default = readr::col_skip()
      )
    )
    t$target <- target
    t$haplotype <- haplotype

    tibbles[[i]] <- t
    i <- i + 1
  }
}

t <- dplyr::bind_rows(tibbles)

t$target <- as.factor(t$target)
t$haplotype <- as.factor(t$haplotype)


ggplot(t, aes(x = haplotype, y = ic50, fill = target)) +
  scale_fill_manual(values = c("human" = "#ffffff", "covid" = "#cccccc")) +
  geom_boxplot(position = position_dodge(), color = "#000000") +
  scale_y_log10() +
  xlab("Haplotype") +
  ylab("Estimated IC50 (nM)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggsave("fig_ic50_distribution.png", width = 7, height = 7)


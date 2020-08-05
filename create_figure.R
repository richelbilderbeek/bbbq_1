# Creates a figure from 'table_1.csv' or 'table_2.csv'
# to show the measured the number of binders and the
# number of binders that are TMH
#
# Usage:
#
#  Rscript create_figure.R [MHC]
#
#  * [MHC] is either 'mhc1' or 'mhc2'
#
#
#
#
library(dplyr)
library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  args <- "mhc1"
}
expect_equal(length(args), 1)
message("Running with argument '", args[1], "'")
mhc <- args[1]
message("mhc: '", mhc, "'")
expect_equal(4, stringr::str_length(mhc))
mhc_class <- stringr::str_sub(mhc, 4, 4)
message("mhc_class: '", mhc_class, "'")

haplotypes_filename <- "haplotypes.csv"
message("'haplotypes_filename': '", haplotypes_filename, "'")
testthat::expect_true(file.exists(haplotypes_filename))
t_haplotypes <- readr::read_csv(haplotypes_filename)

table_filename <- "table_tmh_binders_raw.csv"
message("table_filename: '", table_filename, "'")
testthat::expect_true(file.exists(table_filename))
t_tmh_binders <- readr::read_csv(table_filename)
t_tmh_binders$f_tmh <- NA
t_tmh_binders$f_tmh <- t_tmh_binders$n_binders_tmh / t_tmh_binders$n_binders
t_tmh_binders$haplotype <- NA
for (i in seq_len(nrow(t_tmh_binders))) {
  id <- t_tmh_binders$haplotype_id[i]
  t_tmh_binders$haplotype[i] <- t_haplotypes$haplotype[t_haplotypes$haplotype_id == id]
}
t_tmh_binders$haplotype <- as.factor(t_tmh_binders$haplotype)

all_csv_filenames <- list.files(pattern = "*.csv")
target_filenames <- stringr::str_subset(all_csv_filenames, pattern = "coincidence")
targets <- stringr::str_match(target_filenames, "(.*)_coincidence.csv")[, 2]
message("targets: ", targets)

t_coincidence <- list()
for (i in seq_along(targets)) {
  target  <- targets[i]
  filename <- paste0(target, "_coincidence.csv")
  testthat::expect_true(file.exists(filename))
  t <- readr::read_csv(filename)
  t <- t %>%
    summarise(
      n_spots = sum(n_spots),
      n_spots_tmh = sum(n_spots_tmh),
      .groups = "keep"
  )
  t$target <- target
  t_coincidence[[i]] <- t
}
t_coincidence <- bind_rows(t_coincidence)
t_coincidence$f_tmh <- NA
t_coincidence$f_tmh <- t_coincidence$n_spots_tmh / t_coincidence$n_spots

f_human <- t_coincidence$f_tmh[t_coincidence$target == "human"]
f_covid <- t_coincidence$f_tmh[t_coincidence$target == "covid"]

caption_text <- paste0(
  "Horizontal lines: % 9-mers that overlaps with TMH in ",
  "humans (straight line, ", formatC(100.0 * mean(f_human), digits = 3),"%), \n",
  "SARS-Cov2 (dashed line, ", stringr::str_trim(formatC(100.0 * mean(f_covid), digits = 3)),"%)"
)
caption_text

names(t_tmh_binders)
library(ggplot2)
p <- ggplot(t_tmh_binders, aes(x = haplotype, y = f_tmh, fill = target)) +
  scale_fill_manual(values = c("human" = "#ffffff", "covid" = "#cccccc")) +
  geom_col(position = position_dodge(), color = "#000000") +
  xlab("HLA haplotype") +
  ylab("Epitopes overlapping \nwith transmembrane helix") +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 2),
    breaks = seq(0.0, 1.0, by = 0.1),
    minor_breaks = seq(0.0, 1.0, by = 0.1)
    # limits = c(0, 1.0)
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(yintercept = f_human) +
  geom_hline(yintercept = f_covid, lty = "dashed") +
  labs(
    title = "% epitopes that overlap with TMH per haplotype",
    caption = caption_text
  )
p

png_filename <- paste0("fig_f_tmh_mhc", mhc_class, ".png")

p + ggsave(png_filename, width = 7, height = 7)


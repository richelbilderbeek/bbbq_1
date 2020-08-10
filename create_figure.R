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
the_mhc_class <- mhc_class
message("the_mhc_class: '", the_mhc_class, "'")

target_filename <- paste0("fig_f_tmh_mhc", mhc_class, ".png")
message("target_filename: '", target_filename, "'")
target_filename_grid <- paste0("fig_f_tmh_mhc", mhc_class, "_grid.png")
message("target_filename_grid: '", target_filename_grid, "'")


haplotypes_filename <- "haplotypes.csv"
message("'haplotypes_filename': '", haplotypes_filename, "'")
testthat::expect_true(file.exists(haplotypes_filename))
t_haplotypes <- readr::read_csv(haplotypes_filename)

t_haplotypes$name <- mhcnuggetsr::to_mhcnuggets_names(t_haplotypes$haplotype)
t_haplotypes$mhc_class <- NA
t_haplotypes$mhc_class[t_haplotypes$name %in% mhcnuggetsr::get_mhc_1_haplotypes()] <- 1
t_haplotypes$mhc_class[t_haplotypes$name %in% mhcnuggetsr::get_mhc_2_haplotypes()] <- 2
# Only keep the desired MHC class
t_haplotypes <- t_haplotypes %>% filter(mhc_class == the_mhc_class)



table_filename <- "table_tmh_binders_raw.csv"
message("table_filename: '", table_filename, "'")
testthat::expect_true(file.exists(table_filename))
t_tmh_binders <- readr::read_csv(table_filename)
# Only keep the desired MHC class
t_tmh_binders <- t_tmh_binders %>% filter(haplotype_id %in% t_haplotypes$haplotype_id)


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
t_coincidence$target <- as.factor(t_coincidence$target)



f_covid <- t_coincidence$f_tmh[t_coincidence$target == "covid"]
f_human <- t_coincidence$f_tmh[t_coincidence$target == "human"]
f_myco <- t_coincidence$f_tmh[t_coincidence$target == "myco"]

roman_mhc_class <- NA
if (mhc_class == 1) roman_mhc_class <- "I"
if (mhc_class == 2) roman_mhc_class <- "II"

caption_text <- paste0(
  "Horizontal lines: % 9-mers that overlaps with TMH in ",
  "humans (dotted line, ", formatC(100.0 * mean(f_human), digits = 3),"%), \n",
  "Mycobacterium (dashed line, ", formatC(100.0 * mean(f_myco), digits = 3),"%), \n",
  "SARS-Cov2 (solid line, ", stringr::str_trim(formatC(100.0 * mean(f_covid), digits = 3)),"%)"
)
caption_text

names(t_tmh_binders)
library(ggplot2)
p <- ggplot(t_tmh_binders, aes(x = haplotype, y = f_tmh, fill = target)) +
  scale_fill_manual(values = c("human" = "#ffffff", "covid" = "#cccccc", "myco" = "#888888")) +
  geom_col(position = position_dodge(), color = "#000000") +
  xlab(paste0("MHC-", roman_mhc_class, " HLA haplotype")) +
  ylab("Epitopes overlapping \nwith transmembrane helix") +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 2),
    breaks = seq(0.0, 1.0, by = 0.1),
    minor_breaks = seq(0.0, 1.0, by = 0.1)
    # limits = c(0, 1.0)
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_hline(data = t_coincidence, aes(yintercept = f_tmh, lty = target)) +
  labs(
    title = "% epitopes that overlap with TMH per haplotype",
    caption = caption_text
  )
p


p + ggsave(target_filename, width = 7, height = 7)

p + facet_grid(target ~ ., scales = "free") +
  ggsave(target_filename_grid, width = 7, height = 7)


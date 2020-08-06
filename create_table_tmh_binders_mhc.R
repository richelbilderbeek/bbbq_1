# Merges all tables for MHC-I or MHC-II,
# that have measured the number of binders and the
# number of binders that are TMH
#
# Usage:
#
#  Rscript create_table_tmh_binders_mhc.R [MHC]
#
#  * [MHC] is either 'mhc1' or 'mhc2'
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
the_mhc_class <- mhc_class # Needed for filtering later

target_csv_filename <- paste0("table_tmh_binders_mhc", mhc_class, ".csv")
message("target_csv_filename: '", target_csv_filename, "'")

target_latex_filename <- paste0("table_tmh_binders_mhc", mhc_class, ".latex")
message("target_latex_filename: '", target_latex_filename, "'")

percentile <- bbbq::get_ic50_percentile_binder()
message("'percentile': '", percentile, "' (as hard-coded by BBBQ)")


raw_table_filename <- "table_tmh_binders_raw.csv"
testthat::expect_true(file.exists(raw_table_filename))
t_raw <- readr::read_csv(raw_table_filename)

# Create the BBBQ haplotype LUT
haplotypes_filename <- "haplotypes.csv"
message("haplotypes_filename: '", haplotypes_filename, "'")
expect_true(file.exists(haplotypes_filename))
t_haplotypes <- readr::read_csv(haplotypes_filename)
t_haplotypes$name <- mhcnuggetsr::to_mhcnuggets_names(t_haplotypes$haplotype)
t_haplotypes$mhc_class <- NA
t_haplotypes$mhc_class[t_haplotypes$name %in% mhcnuggetsr::get_mhc_1_haplotypes()] <- 1
t_haplotypes$mhc_class[t_haplotypes$name %in% mhcnuggetsr::get_mhc_2_haplotypes()] <- 2
# Only keep the desired MHC class
t_haplotypes <- t_haplotypes %>% filter(mhc_class == the_mhc_class)

t_long <- t_raw %>% dplyr::filter(haplotype_id %in% t_haplotypes$haplotype_id)
t_long$f <- 100.0 * t_long$n_binders_tmh / t_long$n_binders
t_long$f <- paste0(
  format(t_long$f, digits = 4), " ",
  "(", t_long$n_binders_tmh, "/", t_long$n_binders, ")"
)
t_long$haplotype <- NA
for (i in seq_len(nrow(t_long))) {
  id <- t_long$haplotype_id[i]
  t_long$haplotype[i] <- t_haplotypes$haplotype[id == t_haplotypes$haplotype_id]
}
t_long <- t_long %>% dplyr::select(target, haplotype, f)

names(t_long)
t_long$target <- as.factor(t_long$target)

# Wide form
t_wide <- tidyr::pivot_wider(
  t_long,
  names_from = "target",
  values_from = "f"
)
readr::write_csv(t_wide, target_csv_filename)


roman_mhc_class <- NA
if (mhc_class == 1) roman_mhc_class <- "I"
if (mhc_class == 2) roman_mhc_class <- "II"

knitr::kable(
  t_wide, "latex",
  caption = paste0(
    "Percentage of MHC-", roman_mhc_class, " epitopes overlapping with TMH. ",
    "Values in brackets show the number of binders ",
    "that have at least one residue overlapping with a TMH (first value)",
    "as well as the number of binders (second value). ",
    "Percentile used: ", percentile
  ),
  label = paste0("tmh_binders_mhc", mhc_class)
) %>% cat(., file = target_latex_filename)

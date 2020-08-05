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



raw_table_filename <- "table_tmh_binders_raw.csv"
testthat::expect_true(file.exists(raw_table_filename))
t_raw <- readr::read_csv(raw_table_filename)

# Create the BBBQ haplotype LUT
haplotype_lut <- tibble::tibble(
  formal_name = bbbq::get_mhc_haplotypes(),
  id = NA,
  mhc_class = NA
)
haplotype_lut$id <- paste0("h", seq(1, nrow(haplotype_lut)))
haplotype_lut$haplotype <- mhcnuggetsr::to_mhcnuggets_names(haplotype_lut$formal_name)
haplotype_lut
# Find the haplotypes of the correct MHC class
haplotype_lut$mhc_class[haplotype_lut$haplotype %in% mhcnuggetsr::get_mhc_1_haplotypes()] <- 1
haplotype_lut$mhc_class[haplotype_lut$haplotype %in% mhcnuggetsr::get_mhc_2_haplotypes()] <- 2
haplotype_ids <- haplotype_lut$id[haplotype_lut$mhc_class == mhc_class]

library(dplyr)

t_long <- t_raw %>% dplyr::filter(haplotype_id %in% haplotype_ids)
t_long$f <- 100.0 * t_long$n_binders_tmh / t_long$n_binders
t_long$f <- paste0(
  format(t_long$f, digits = 4), " ",
  "(", t_long$n_binders_tmh, "/", t_long$n_binders, ")"
)
t_long$haplotype <- NA
for (i in seq_len(nrow(t_long))) {
  t_long$haplotype[i] <- haplotype_lut$haplotype[t_long$haplotype_id[i] == haplotype_lut$id]
}


t_long

# One tibble per target
tibbles <- list()

for (target in targets) {
  coincidence_filename <- paste0(target, "_coincidence.csv")
  testthat::expect_true(file.exists(coincidence_filename))
  binders_filename <- paste0(target, "_binders.csv")
  testthat::expect_true(file.exists(binders_filename))
  t_coincidence <- readr::read_csv(coincidence_filename)

  t_binders <- readr::read_csv(binders_filename)
  t_binders
}




all_target_haplotype_files <- stringr::str_subset(
  all_csv_files,
  paste0(".*_h[:digit:]{1,3}_ic50s")
)
all_target_haplotype_files

mhc_files <- rep(NA, length(all_csv_files))
for (i in seq_along(all_csv_files)) {

}

# Only select files for one MHC class,
# which always start as, for example, "mhc1_"
mhc_files <- stringr::str_subset(
  all_csv_files,
  paste0("^", mhc, "_")
)

library(magrittr)
library(dplyr)
tibbles <- list()

for (i in seq_along(mhc_files)) {

  mhc_file <- mhc_files[i]

  t <- readr::read_csv(
    file = mhc_file,
    col_types = readr::cols(
      haplotype = readr::col_character(),
      n_binders = readr::col_double(),
      n_binders_tmh = readr::col_double()
    )
  )
  t$f <- 100.0 * t$n_binders_tmh / t$n_binders
  t$f <- paste0(
    format(t$f, digits = 4), " ",
    "(", t$n_binders_tmh, "/", t$n_binders, ")"
  )
  t <- t %>% dplyr::select(haplotype, f)
  t$target <- stringr::str_match(mhc_file, "^mhc._(.*).csv$")[2]
  tibbles[[i]] <- t
}

# Long form
t <- dplyr::bind_rows(tibbles)

# Wide form
t <- tidyr::pivot_wider(
  t,
  names_from = "target",
  values_from = "f"
)
filename <- paste0("table_", mhc_class, ".csv")
readr::write_csv(t, filename)

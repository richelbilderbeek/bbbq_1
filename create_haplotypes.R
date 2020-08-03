# Creates the 'haplotypes.csv' file, which maps a haplotype to its ID
#
# Usage:
#
#   Rscript create_haplotypes.R

target_filename <- "haplotypes.csv"

t <- tibble::tibble(
  haplotype = bbbq::get_mhc_haplotypes(),
  haplotype_id = NA
)
t$haplotype_id <- paste0("h", seq(1, nrow(t)))

readr::write_csv(t, target_filename)

testthat::expect_true(file.exists(target_filename))

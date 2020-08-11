# Creates the 'haplotypes.csv' file, which maps a haplotype to its ID
#
# Usage:
#
#   Rscript create_haplotypes.R

target_filename <- "haplotypes_lut.csv"
message("'target_filename': ", target_filename)

t <- bbbq::create_haplotypes_lut()

readr::write_csv(t, target_filename)

testthat::expect_true(file.exists(target_filename))

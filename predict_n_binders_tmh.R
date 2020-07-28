# Predict the number of binders and the number of binders that are TMH
#
# Usage:
#
#   Rscript predict_n_binders_tmh.R [MHC] [target]
#
# * [MHC]: either 'mhc1' or 'mhc2'
# * [target]: either 'test', 'covid', 'human', 'myco'
#
# For example:
#
#   Rscript predict_n_binders_tmh.R mhc1 test
#
library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
  args <- c("mhc1", "test")
}
expect_equal(length(args), 2)
message("Running with arguments '", args[1], "' and '", args[2], "'")

mhc <- args[1]
target_name <- args[2]

message("mhc: '", mhc, "'")
message("target_name: '", target_name, "'")
filename <- paste0(mhc, "_", target_name, ".csv")
message("filename: '", filename, "'")

library(bbbq)

haplotypes <- NA
if (mhc == "mhc1") {
  haplotypes <- get_mhc1_haplotypes()
} else {
  expect_equal(mhc, "mhc2")
  haplotypes <- get_mhc2_haplotypes()
}

t <- predict_n_binders_tmh(
  target_name = target_name,
  haplotypes = haplotypes,
  n_aas = 9,
  percentile = 0.05
)
readr::write_csv(t, filename)

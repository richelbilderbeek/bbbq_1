# Predict the IC50s
#
# Usage:
#
#   Rscript predict_ic50s.R [target] [haplotype_id]
#
# * [target]: either 'covid', 'human', 'myco'
# * [haplotype_id]: a haplotype ID as stored in 'haplotypes_lut.csv'
#
# For example:
#
#   Rscript predict_ic50s.R covid h1
#
library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) {
  args <- c("covid", "h1")
}
expect_equal(length(args), 2)
message("Running with arguments '", args[1], "' and '", args[2], "'")

target_name <- args[1]
haplotype_id <- args[2]

message("target_name: '", target_name, "'")
message("haplotype_id: '", haplotype_id, "'")

haplotypes_filename <- "haplotypes_lut.csv"
message("haplotypes_filename: '", haplotypes_filename, "'")
expect_true(file.exists(haplotypes_filename))

t_haplotypes <- readr::read_csv(haplotypes_filename)
haplotype <- t_haplotypes$haplotype[t_haplotypes$haplotype_id == haplotype_id]
message("'haplotype' (formal name): ", haplotype)

peptides_filename <- paste0(target_name, "_peptides.csv")
message("peptides_filename: '", peptides_filename, "'")
expect_true(file.exists(peptides_filename))

target_filename <- paste0(target_name, "_", haplotype_id, "_ic50s.csv")
message("target_filename: '", target_filename, "'")

if (file.exists(target_filename)) {
  message("'target_filename' already exists. Done!")
  q()
}

t_peptides <- readr::read_csv(peptides_filename)

mhcnuggets_options <- mhcnuggetsr::create_mhcnuggets_options(
  mhc = mhcnuggetsr::to_mhcnuggets_name(haplotype)
)
message("'mhcnuggets_options$mhc' (MHCnuggets filename): ", mhcnuggets_options$mhc)

t_ic50s <- mhcnuggetsr::predict_ic50(
  mhcnuggets_options = mhcnuggets_options,
  peptides = t_peptides$peptide
)

expect_equal(t_peptides$peptide, t_ic50s$peptide)

t <- tibble::tibble(
  protein_id = t_peptides$protein_id,
  start_pos = t_peptides$start_pos,
  ic50 = t_ic50s$ic50
)
readr::write_csv(t, target_filename)
testthat::expect_true(file.exists(target_filename))

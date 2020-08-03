# Predict the number of binders and the number of binders that are TMH
#
# Usage:
#
#   Rscript predict_n_binders_tmh.R [target]
#
# * [target]: either , 'covid', 'human', 'myco'
#
# For example:
#
#   Rscript predict_n_binders_tmh.R covid
#
library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  args <- c("covid")
}
testthat::expect_equal(length(args), 1)
message("Running with arguments '", args[1], "'")

target_name <- args[1]

message("target_name: '", target_name, "'")
target_filename <- paste0(target_name, "_binders.csv")
message("target_filename: '", target_filename, "'")

haplotypes_filename <- "haplotypes.csv"
testthat::expect_true(file.exists(haplotypes_filename))
t_haplotypes <- readr::read_csv(haplotypes_filename)

peptides_filename <- paste0(target_name, "_peptides.csv")
message("peptides_filename: '", peptides_filename, "'")
testthat::expect_true(file.exists(peptides_filename))
t_peptides <- readr::read_csv(peptides_filename)
peptide_length <- nchar(t_peptides$peptide[1])

topology_filename <- paste0(target_name, "_topology.csv")
message("topology_filename: '", topology_filename, "'")
testthat::expect_true(file.exists(topology_filename))
t_topologies <- readr::read_csv(topology_filename)

tibbles <- list()

for (i in seq_len(nrow(t_haplotypes))) {
  haplotype <- t_haplotypes$haplotype[i]
  haplotype
  haplotype_id <- t_haplotypes$haplotype_id[i]
  haplotype_id
  ic50s_filename <- paste0(target_name, "_", haplotype_id, "_ic50s.csv")
  testthat::expect_true(file.exists(ic50s_filename))
  t_ic50s <- readr::read_csv(ic50s_filename)

  HIERO

  for (j in seq_len(nrow(t_topologies))) {
    topology <- t_topologies$topology[j]
    topologies <- stringr::str_sub(
      topology,
      seq(1, nchar(topology) - peptide_length + 1),
      seq(peptide_length, nchar(topology))
    )
    n_spots <- length(topologies)
    which_tmh <- stringr::str_which(topologies, "1")
    n_spots_tmh <- length(which_tmh)
  }
  EN HIERO OOK EEN BEETJE

}




readr::write_csv(t, target_filename)
testthat::expect_true(file.exists(target_filename))

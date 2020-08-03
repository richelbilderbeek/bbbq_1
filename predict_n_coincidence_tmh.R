# Predict the number of spots and the number of spots
# that overlap with a TMH
#
# Usage:
#
#   Rscript predict_n_coincidence_tmh.R [target]
#
# * [target]: either 'test', 'covid', 'human', 'myco'
#
# For example:
#
#   Rscript predict_n_coincidence_tmh.R test
#
# Output:
#
#  * File named [target]_coincidence.csv
#
library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  args <- "covid"
}
testthat::expect_equal(length(args), 1)
message("Running with argument '", args[1], "''")

target_name <- args[1]
message("target_name: '", target_name, "'")

target_filename <- paste0(target_name, "_coincidence.csv")
message("target_filename: '", target_filename, "'")

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

for (i in seq_len(nrow(t_topologies))) {
  topology <- t_topologies$topology[i]
  topologies <- stringr::str_sub(
    topology,
    seq(1, nchar(topology) - peptide_length + 1),
    seq(peptide_length, nchar(topology))
  )
  n_spots <- length(topologies)
  which_tmh <- stringr::str_which(topologies, "1")
  n_spots_tmh <- length(which_tmh)

  tibbles[[i]] <- tibble::tibble(
    protein_id = t_topologies$protein_id[i],
    n_spots = n_spots,
    n_spots_tmh = n_spots_tmh
  )
}

t <- dplyr::bind_rows(tibbles)

readr::write_csv(t, target_filename)
testthat::expect_true(file.exists(target_filename))

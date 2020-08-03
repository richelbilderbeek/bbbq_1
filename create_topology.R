# Create the topology for a target
#
# Usage:
#
#   Rscript create_topology.R [target]
#
# * [target]: either 'covid', 'human', 'myco'
#
# For example:
#
#   Rscript create_topology.R covid
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

proteins_filename <- paste0(target_name, "_proteins.csv")
message("proteins_filename: '", proteins_filename, "'")
testthat::expect_true(file.exists(proteins_filename))

target_filename <- paste0(target_name, "_topology.csv")
message("target_filename: '", target_filename, "'")

if (file.exists(target_filename)) {
  message("'target_filename' already exists. Done!")
  q()
}

t_proteins <- readr::read_csv(proteins_filename)

t_topology <- tibble::tibble(
  protein_id = t_proteins$protein_id,
  topology = NA
)

for (i in seq_len(nrow(t_proteins))) {
  t_topology$topology[i] <- pureseqtmr::predict_topology_from_sequence(
    protein_sequence = t_proteins$sequence[i]
  )
}

readr::write_csv(t_topology, target_filename)
testthat::expect_true(file.exists(target_filename))

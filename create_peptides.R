# Create the peptides for a target
#
# Usage:
#
#   Rscript create_peptides.R [target]
#
# * [target]: either 'covid', 'human', 'myco'
#
# For example:
#
#   Rscript create_peptides.R covid
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

peptide_length <- 9
message("peptide_length: '", peptide_length, "'")

target_filename <- paste0(target_name, "_peptides.csv")
message("target_filename: '", target_filename, "'")



t_proteins <- readr::read_csv(proteins_filename)


tibbles <- list()

n_proteins <- nrow(t_proteins)

for (i in seq_len(n_proteins)) {
  sequence <- t_proteins$sequence[i]

  this_t <- tibble::tibble(
    peptide = stringr::str_sub(
      sequence,
      seq(1, nchar(sequence) - peptide_length + 1),
      seq(peptide_length, nchar(sequence))
    ),
    protein_id = t_proteins$protein_id[i],
    start_pos = NA
  )
  this_t$start_pos <- seq(1, nrow(this_t))
  tibbles[[i]] <- this_t
}

t <- dplyr::bind_rows(tibbles)

readr::write_csv(t, target_filename)
testthat::expect_true(file.exists(target_filename))

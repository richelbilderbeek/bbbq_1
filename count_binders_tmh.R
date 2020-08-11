# Count the number of binders and the number of binders that are TMH
#
# Usage:
#
#   Rscript count_binders_tmh.R [target]
#
# * [target]: either , 'covid', 'human', 'myco'
#
# For example:
#
#   Rscript count_binders_tmh.R covid
#
library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  args <- c("covid")
}
testthat::expect_equal(length(args), 1)
message("Running with argument '", args[1], "'")

target_name <- args[1]
message("target_name: '", target_name, "'")

percentile <- bbbq::get_ic50_percentile_binder()
message("'percentile': '", percentile, "' (as hard-coded by BBBQ)")

target_filename <- paste0(target_name, "_binders.csv")
message("target_filename: '", target_filename, "'")

haplotypes_filename <- "haplotypes_lut.csv"
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

# Separate the topology per peptide
topology_lengths <- stringr::str_length(t_topologies$topology)
topology_peptide_lengts <- topology_lengths - peptide_length + 1
t_topology_peptide <- tibble::tibble(
  protein_id = rep(t_topologies$protein_id, times = topology_peptide_lengts),
  start_pos = sequence(topology_peptide_lengts),
  topology = NA,
  is_tmh = NA
)
for (i in seq_len(nrow(t_topology_peptide))) {
  protein_id <- t_topology_peptide$protein_id[i]
  start_pos <- t_topology_peptide$start_pos[i]
  protein_topology <- t_topologies$topology[t_topologies$protein_id == protein_id]
  peptide_topology <- stringr::str_sub(protein_topology, start_pos, start_pos + peptide_length - 1)
  testthat::expect_equal(peptide_length, stringr::str_length(peptide_topology))
  t_topology_peptide$topology[i] <- peptide_topology
  t_topology_peptide$is_tmh[i] <- stringr::str_count(peptide_topology, "1") > 0
}
t_topology_peptide

# One tibble per haplotype
tibbles <- list()

n_haplotypes <- nrow(t_haplotypes)
for (i in seq_len(n_haplotypes)) {
  haplotype_id <- t_haplotypes$haplotype_id[i]
  haplotype_id
  ic50s_filename <- paste0(target_name, "_", haplotype_id, "_ic50s.csv")
  testthat::expect_true(file.exists(ic50s_filename))
  t_ic50s <- readr::read_csv(ic50s_filename)
  testthat::expect_equal(nrow(t_topology_peptide), nrow(t_ic50s))
  testthat::expect_true(all(t_topology_peptide$protein_id == t_ic50s$protein_id))
  testthat::expect_true(all(t_topology_peptide$start_pos == t_ic50s$start_pos))

  haplotype <- t_haplotypes$haplotype[t_haplotypes$haplotype_id == haplotype_id]
  haplotype
  ic50 <- mhcnpreds::get_ic50_threshold(
    peptide_length = peptide_length,
    mhc_haplotype = mhcnuggetsr::to_mhcnuggets_name(haplotype),
    percentile = percentile
  )
  ic50

  t <- tibble::tibble(
    protein_id = t_ic50s$protein_id,
    is_binder = t_ic50s$ic50 < ic50,
    is_tmh = t_topology_peptide$is_tmh
  )
  sum_t <- t %>% dplyr::group_by(protein_id) %>%
    dplyr::summarise(
      n_binders = sum(is_binder == TRUE),
      n_binders_tmh = sum(is_binder == TRUE & is_tmh == TRUE),
      .groups = "keep"
    )
  sum_t$haplotype_id <- haplotype_id
  sum_t <- sum_t %>% dplyr::relocate(haplotype_id)
  tibbles[[i]] <- sum_t
}

t <- dplyr::bind_rows(tibbles)
readr::write_csv(t, target_filename)
testthat::expect_true(file.exists(target_filename))

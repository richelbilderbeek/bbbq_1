# Merges all tables for MHC-I and MHC-II,
# that have measured the number of binders and the
# number of binders that are TMH
#
# Usage:
#
#  Rscript create_raw_table.R
#

library(testthat)

targets <- c("covid", "human", "myco")

# One tibble per target
tibbles <- list()

for (i in seq_along(targets)) {
  target <- targets[i]
  binders_filename <- paste0(target, "_binders.csv")
  if (!file.exists(binders_filename)) next()
  testthat::expect_true(file.exists(binders_filename))
  t_binders <- readr::read_csv(binders_filename)
  t <- t_binders %>% dplyr::group_by(haplotype_id) %>%
    dplyr::summarize(
      n_binders = sum(n_binders),
      n_binders_tmh = sum(n_binders_tmh),
      .groups = "keep"
    )
  t$target <- target
  t <- t %>% dplyr::relocate(target)
  tibbles[[i]] <- t
}

t <- dplyr::bind_rows(tibbles)

filename <- paste0("table_tmh_binders_raw.csv")
readr::write_csv(t, filename)

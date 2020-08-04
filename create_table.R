# Merges all tables for MHC-I or MHC-II,
# that have measured the number of binders and the
# number of binders that are TMH
#
# Usage:
#
#  Rscript create_table.R [MHC]
#
#  * [MHC] is either 'mhc1' or 'mhc2'
#

library(testthat)

args <- commandArgs(trailingOnly = TRUE)
if (1 == 2) {
  args <- "mhc1"
}
expect_equal(length(args), 1)
message("Running with argument '", args[1], "'")
mhc <- args[1]
message("mhc: '", mhc, "'")
expect_equal(4, stringr::str_length(mhc))
mhc_class <- stringr::str_sub(mhc, 4, 4)
message("mhc_class: '", mhc_class, "'")


haplotype_lut <- mhcnpreds::get_haplotype_lut()
haplotype_lut$mhc_class[haplotype_lut$haplotype %in% mhcnuggetsr::get_mhc_1_haplotypes()] <- 1
haplotype_lut$mhc_class[haplotype_lut$haplotype %in% mhcnuggetsr::get_mhc_2_haplotypes()] <- 2

haplotype_ids <- haplotype_lut$id[haplotype_lut$mhc_class == mhc_class]

coincidence_files <- list.files(pattern = "*_coincidence.csv")
binders_files <- list.files(pattern = "*_binders.csv")

all_target_haplotype_files <- stringr::str_subset(
  all_csv_files,
  paste0(".*_h[:digit:]{1,3}_ic50s")
)
all_target_haplotype_files

mhc_files <- rep(NA, length(all_csv_files))
for (i in seq_along(all_csv_files)) {

}

# Only select files for one MHC class,
# which always start as, for example, "mhc1_"
mhc_files <- stringr::str_subset(
  all_csv_files,
  paste0("^", mhc, "_")
)

library(magrittr)
library(dplyr)
tibbles <- list()

for (i in seq_along(mhc_files)) {

  mhc_file <- mhc_files[i]

  t <- readr::read_csv(
    file = mhc_file,
    col_types = readr::cols(
      haplotype = readr::col_character(),
      n_binders = readr::col_double(),
      n_binders_tmh = readr::col_double()
    )
  )
  t$f <- 100.0 * t$n_binders_tmh / t$n_binders
  t$f <- paste0(
    format(t$f, digits = 4), " ",
    "(", t$n_binders_tmh, "/", t$n_binders, ")"
  )
  t <- t %>% dplyr::select(haplotype, f)
  t$target <- stringr::str_match(mhc_file, "^mhc._(.*).csv$")[2]
  tibbles[[i]] <- t
}

# Long form
t <- dplyr::bind_rows(tibbles)

# Wide form
t <- tidyr::pivot_wider(
  t,
  names_from = "target",
  values_from = "f"
)
filename <- paste0("table_", mhc_class, ".csv")
readr::write_csv(t, filename)

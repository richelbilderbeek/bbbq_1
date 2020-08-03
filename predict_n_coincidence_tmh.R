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
  args <- "test"
}
expect_equal(length(args), 1)
message("Running with argument '", args[1], "''")

target_name <- args[1]

message("target_name: '", target_name, "'")
filename <- paste0(target_name, "_coincidence.csv")
message("filename: '", filename, "'")

library(bbbq)

if (beastier::is_on_travis()) {
  message("Running on Travis, setting 'target' to 'test'")
  target_name <- "test"
}

t <- predict_n_coincidence_tmh(
  target_name = target_name,
  n_aas = 9
)

readr::write_csv(t, filename)

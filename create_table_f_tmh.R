# Create 'table_f_tmh.latex'
#
# Usage:
#
#   Rscript create_table_f_tmh.R
#
# For example:
#
#   Rscript create_table_f_tmh.R
#
# Output:
#
#  * File named 'table_f_tmh.latex'
#
library(testthat)

target_latex_filename <- "table_f_tmh.latex"
message("'target_latex_filename': '", target_latex_filename, "'")

targets <- c("covid", "myco", "human")

library(dplyr)
tibbles <- list()

for (i in seq_along(targets)) {
  target <- targets[i]
  filename <- paste0(target, "_coincidence.csv")
  if (!file.exists(filename)) next
  t <- readr::read_csv(filename)
  t$protein_id <- as.factor(t$protein_id)
  t <- t %>%
    dplyr::summarise(
      n_spots = sum(n_spots),
      n_spots_tmh = sum(n_spots_tmh),
      .groups = "keep"
    )
  t$target <- target
  tibbles[[i]] <- t
}

t <- dplyr::bind_rows(tibbles)
t$target <- as.factor(t$target)

t_wide <- tidyr::pivot_wider(
  t,
  values_from = c(n_spots, n_spots_tmh)
)
names(t_wide) <- stringr::str_replace(names(t_wide), "_$", "")
names(t_wide)
t_wide$f_tmh <- format(100.0 * (t$n_spots_tmh / t$n_spots), digits = 3)

knitr::kable(
  t_wide, "latex",
  caption = paste0(
    "Percentage of spots and spots that overlap with a TMH"
  ),
  label = "f_tmh"
) %>% cat(., file = target_latex_filename)

# Creates a figure from 'table_1.csv' or 'table_2.csv'
# to show the measured the number of binders and the
# number of binders that are TMH
#
# Usage:
#
#  Rscript create_figure.R [MHC]
#
#  * [MHC] is either 'mhc1' or 'mhc2'
#
#
#
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

table_filename <- paste0("table_", mhc_class, ".csv")
message("table_filename: '", table_filename, "'")
testthat::expect_true(file.exists(table_filename))

t_wide <- readr::read_csv(table_filename)

# Extract the percentages and convert these to fractions
for (col_index in seq(2, ncol(t_wide))) {
  # Direct conversion from tibble column to char vector fails
  text <- as.matrix(t_wide[, col_index])[, 1]
  percs <- stringr::str_replace(
    string = text,
    pattern = "^(.*) \\(.*\\)$",
    replacement = "\\1"
  )
  t_wide[, col_index] <- as.numeric(percs) / 100.0
}
t_wide

t_long <- tidyr::pivot_longer(
  t_wide,
  !haplotype,
  names_to = "target",
  values_to = "f"
)
t_long$target <- as.factor(t_long$target)
t_long

library(ggplot2)

t_coincidence <- tibble::tibble(
  target = c("human", "covid", "myco"),
  n_spots = 1,
  n_spots_tmh = 0,
  f = NA
)
t_coincidence$f <- mean(t_long$f) * seq(0.9, 1.1, by = 0.1)

for (i in seq_along(t_coincidence$target)) {
  target <- t_coincidence$target[i]
  filename <- paste0(target, "_coincidence.csv")
  if (!file.exists(filename)) next()
  this_t <- readr::read_csv(filename)
  t_coincidence$n_spots[i] <- this_t$n_spots
  t_coincidence$n_spots_tmh[i] <- this_t$n_spots_tmh
  t_coincidence$f[i] <- this_t$n_spots_tmh / this_t$n_spots
}

f_human <- t_coincidence$f[t_coincidence$target == "human"]
f_covid <- t_coincidence$f[t_coincidence$target == "covid"]
f_myco <- t_coincidence$f[t_coincidence$target == "myco"]

t_coincidence


caption_text <- paste0(
  "Horizontal lines: % 9-mers that overlaps with TMH in ",
  #"humans (straight line, ", formatC(100.0 * mean(f_human), digits = 3),"%), \n",
  "SARS-Cov2 (dashed line, ", stringr::str_trim(formatC(100.0 * mean(f_covid), digits = 3)),"%)"
  #"Mycoplasma (dotted line, ", formatC(100.0 * mean(f_myco), digits = 3),"%)"
)

p <- ggplot(t_long %>% dplyr::filter(target == "covid"), aes(x = haplotype, y = f, fill = target)) +
  scale_fill_manual(values = c("human" = "#ffffff", "covid" = "#cccccc", "myco" = "#999999", "test" = "#999999")) +
  geom_col(position = position_dodge(), color = "#000000") + xlab("HLA haplotype") +
  ylab("Epitopes overlapping \nwith transmembrane helix") +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 2),
    breaks = seq(0.0, 1.0, by = 0.1),
    minor_breaks = seq(0.0, 1.0, by = 0.1)
    # limits = c(0, 1.0)
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  #geom_hline(yintercept = f_human) +
  geom_hline(yintercept = f_covid, lty = "dashed") +
  #geom_hline(yintercept = f_myco, lty = "dotted") +
  labs(
    title = "% epitopes that overlap with TMH per haplotype",
    caption = caption_text
  )
p

png_filename <- paste0("fig_bbbq_", mhc_class, ".png")

p + ggsave(png_filename, width = 7, height = 7)


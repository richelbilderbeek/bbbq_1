
mhc_classes <- c(1, 2)

for (i in seq_along(mhc_classes)) {
  mhc_class <- mhc_classes[i]
  roman_mhc_class <- NA
  if (mhc_class == 1) roman_mhc_class <- "I"
  if (mhc_class == 2) roman_mhc_class <- "II"
  filename <- paste0("table_tmh_binders_mhc", mhc_class, ".latex")
  testthat::expect_true(file.exists(filename))
  text <- readr::read_lines(filename)

  # Caption
  if (length(stringr::str_which(text, "my-caption")) == 0) {
    message("Caption already fixed for ", filename)
  } else {
    new_caption <- paste0(
      "Percentage of MHC-", roman_mhc_class, " epitopes overlapping with transmembrane helix."
    )
    text <- stringr::str_replace(
      text,
      "my-caption",
      new_caption
    )
    message("Fixed caption for ", filename)
  }

  # Label
  if (length(stringr::str_which(text, "my-label")) == 0) {
    message("Label already fixed for ", filename)
  } else {
    new_label <- paste0(
      "table:bbbq_", mhc_class, "_percentages"
    )
    text <- stringr::str_replace(
      text,
      "my-label",
      new_label
    )
    message("Fixed label for ", filename)
  }

  readr::write_lines(text, filename)
}




test_that("use", {
  expect_equal(
    get_mhc_peptide_length(1),
    get_mhc1_peptide_length()
  )
  expect_equal(
    get_mhc_peptide_length(2),
    get_mhc2_peptide_length()
  )
})

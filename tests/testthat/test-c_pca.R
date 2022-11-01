test_that("Validating columns", {
  lp <- rutils::validate_json_file("params/pca_parameters.json")
  expect_type(lp,"list")
  validate_parameters("params/pca_parameters.json")

  p <- c_pcaproj(lp)
  print(p)
  expect_s3_class(p,"ggplot")
}
)

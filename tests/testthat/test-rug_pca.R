test_that("Validating columns", {
  lp <- rutils::validate_json_file("params/pca_parameters.json")
  expect_type(lp,"list")
  validate_parameters("params/pca_parameters.json")

  print(iscolor('red'))

  p <- rug_pca(lp,verbose=FALSE)
  print(p)
  expect_s3_class(p,"ggplot")
}
)

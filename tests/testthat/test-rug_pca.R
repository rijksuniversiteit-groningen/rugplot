test_that("Validating columns", {

  lp <- read_rugjson("params/pca_parameters.json","pca")
  expect_type(lp,"list")

  p <- rug_pca(lp,verbose=FALSE)
  print(p)
  expect_s3_class(p,"ggplot")
}
)

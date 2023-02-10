test_that("scatterplot works", {

  lp <- read_rugjson("params/scatter_params.json","scatter")
  expect_type(lp,"list")
  p <- rug_scatter(lp,verbose=TRUE)
  expect_s3_class(p,"ggplot")
  print(p)
})

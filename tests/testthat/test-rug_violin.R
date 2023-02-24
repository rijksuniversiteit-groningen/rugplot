test_that("use", {
  lp <- read_rugjson("params/mpg_params.json","violin")
  expect_type(lp,"list")
  print(lp$aesthetics$factorx)
  p <- rug_violin(lp,verbose=FALSE)
  expect_s3_class(p,"ggplot")
  print(p)
})

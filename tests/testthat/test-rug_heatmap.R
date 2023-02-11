test_that("heatmap works", {
  lp <- read_rugjson("params/heatmap_params.json","heatmap")
  expect_type(lp,"list")
  p <- rug_heatmap(lp,verbose=TRUE)
  expect_s3_class(p,"ggplot")
  print(p)
})

test_that("heatmap works", {
  # options(tikzLatex = "/home/rstudio/bin/lualatex")
  lp <- read_rugjson("params/heatmap_params.json","heatmap")
  expect_type(lp,"list")
  p <- rug_heatmap(lp,verbose=TRUE)
  expect_s3_class(p,"ggplot")
  print(p)
})

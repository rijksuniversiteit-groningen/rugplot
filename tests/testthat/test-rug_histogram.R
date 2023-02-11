test_that("Histogram is created", {

  js <- "params/histogram_params.json"

  lp <- read_rugjson(js,"histogram")
  expect_type(lp,"list")

  w <- capture_warnings(p <- rug_histogram(lp,TRUE))
  # print(length(w))
  print(w[1])
  print(w[2])
  print(p)
  expect_s3_class(p,"ggplot")
  }
)

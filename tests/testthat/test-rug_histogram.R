test_that("Histogram is created", {
  js <- "params/hist_incorrect-col_id.json"

  lp <- rutils::validate_json_file(js)
  expect_type(lp,"list")

  resv <- validate_parameters(js,pschema="histogram_schema.json")
  expect_equal(resv,TRUE)

  w <- capture_warnings(p <- rug_histogram(lp))
  # print(length(w))
  print(w[1])
  print(w[2])
  print(p)
  expect_s3_class(p,"ggplot")
  }
)

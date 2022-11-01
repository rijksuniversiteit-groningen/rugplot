test_that("Validating columns", {
  js <- "params/violinparams_test.json"
  lp <- rutils::validate_json_file(js)
  expect_type(lp,"list")

  validate_parameters(js,pschema="histogram_schema.json")
  # expect_error(histogram("params/hist_incorrect-col_id.json"),
  #              "' length ' must be a column in data/iris.csv")

  p <- c_histogram(lp)
  print(p)
  expect_s3_class(p,"ggplot")
  }
)

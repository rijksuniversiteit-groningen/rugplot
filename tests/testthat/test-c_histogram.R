test_that("Validating columns", {
  lp <- validate_json_file("params/mpg_params.json")
  expect_type(lp,"list")

  validate_parameters("params/mpg_params.json","histogram_schema.json")
  # expect_error(histogram("params/hist_incorrect-col_id.json"),
  #              "' length ' must be a column in data/iris.csv")

  p <- c_histogram(lp)
  print(p)
  expect_s3_class(p,"ggplot")
  }
)

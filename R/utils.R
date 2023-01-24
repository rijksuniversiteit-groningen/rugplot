#' Validate that a  json file meets a required schema
#'
#' @param params a json file to be validated against a schema
#' @param pschema a predefined json schema
#'
#' @export
#' @keywords internal
validate_parameters <- function(params,pschema="pca_projection_schema.json"){
  schemafile <- system.file("extdata", pschema, package = "rugplot")
  jsonvalidate::json_validate(params,schemafile,verbose=TRUE,error=TRUE)
}

select_factors <- function (dt){
  names(Filter(function(x)
    is.factor(x) ||
      is.logical(x) ||
      is.character(x),
    dt))
}

select_numeric <- function (dt){
  names(Filter(function(x)
    is.integer(x) ||
      is.numeric(x) ||
      is.double(x),
    dt))
}



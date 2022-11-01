#' Validate that a  json file meets a required schema
#'
#' @param params a json file to be validated against a schema
#' @param pschema a predefined json schema
#'
#' @export
#' @keywords internal
validate_parameters <- function(params,pschema="pca_projection_schema.json"){
  schemafile <- system.file("extdata", pschema, package = "rvispack")
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

add_facets <- function(splot,lpars,factornames){

  if (!is.null(lpars$facet_row))
      if (lpars$facet_row %in% factornames)
        facets <- paste(lpars$facet_row,"~")
      else {
        warning(paste(lpars$facet_row,"not in:",factornames))
        facets <- ". ~"
      }
  else
    facets <- ". ~"

  if (!is.null(lpars$facet_colum))
      if (lpars$facet_colum %in% factornames)
        facets <- paste(facets,lpars$facet_column)
      else {
        facets <- paste(facets,".")
        warning(paste(lpars$facet_column,"not in: ",factornames))
      }
  else
    facets <- paste(facets,".")

  cat(paste("Facets:",facets),"\n")
  if (facets != ". ~ .")
    splot <- paste(splot, "+ ggplot2::facet_grid(", facets, ")")
  splot
}


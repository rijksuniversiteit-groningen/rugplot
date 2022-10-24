#' Validate that a  json file meets a required schema
#'
#' @param params a json file to be validated against a schema
#' @param pschema a predefined json schema
#'
#' @export
validate_parameters <- function(params,pschema="pca_projection_schema.json"){
  schemafile <- system.file("extdata", pschema, package = "rvispack")
  jsonvalidate::json_validate(params,schemafile,verbose=TRUE,error=TRUE)
}

#' Reads columns from a file in table format
#'
#' Additional info
#' @param filename a string data file name including the relative path
#' @param select_columns a vector including the column names to be read from the data file
#'
#' @return if succeds, this function returns a data table
#' @export
#' @keywords internal
#'
# #' @examples
read_data <- function(filename,select_columns){
  # Check for empty list
  if (length(select_columns)<1) {
    select_columns = NULL
    cat("Reading all columns\n")
  } else {
    cat("Selected columns",select_columns,"\n")
  }
  tryCatch(cols <- data.table::fread(filename,select = select_columns),
           error = function(c) {
             c$message <- paste0(c$message, " (in ", filename, ")")
             stop(c)
             }
           # ,warning = function(c) {
           #   c
           #   }
  )
  # print(cols)
}

#' This function validates a json structure
#'
#' @param fileparams a json structure stored in a file name to be validated
#'
#' @return an R list of parameters extracted from the json structure
#' @export
#'
# #' @examples
validate_json_file <- function(fileparams) {
  if (file.exists(fileparams)){
    tryCatch(lp <-  jsonlite::fromJSON(fileparams),
             error = function(c) {
               c$message <- paste0(c$message, " (in ", fileparams, ")")
               stop(c)
             }
    )
  } else {
    message <- paste0("Parameter file '", fileparams, "' not found.")
    stop(message)
  }
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

# TODO: create functions to display the required parameters in json structure
# TODO: write a function to extract the json structure from the schema

jsonstruct <- function(jsonschema) {
  rjs <- jsonlite::fromJSON(system.file("extdata",jsonschema,package = "pcaprojection"))

  for (p in rjs) {
    print(str(p))
  }
}

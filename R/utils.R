#' Reads the \code{rug} plot parameters from a JSON file
#'
#' @param jsonparams A JSON file to be validated against a schema
#' @param visplot character, a \code{rug} plot
#' @param cds_package The package that contains the JSON schema
#'
#' @export
read_rug_json <- function(jsonparams, visplot, cds_package = "rugplot"){
  # rug_plots_list <- rug_plotsdic()
  # if (!visplot %in% names(rug_plots_list) )
  #   stop("Type error: '", visplot, "' is not a rugplot!")
  # else
  #   jsonschema <- rug_plots_list[visplot]
  jsonschema <- jschema(visplot = visplot)
  schemafile <- system.file("extdata", jsonschema, package = cds_package)
  #schemafile <- file.path(find.package(cds_package), "extdata",jsonschema)
  cat(paste("\nSchema filename: ",schemafile),"\n")
  jsonvalidate::json_validate(jsonparams,schemafile,verbose=TRUE,error=TRUE)
  validate_json_file(jsonparams)
}

#' This function validates a json structure
#'
#' @param jsonparams a json structure stored in a file name to be validated
#'
#' @return an R list of parameters extracted from the json structure
#' @export
#'
#' @keywords internal
#'
# #' @examples
validate_json_file <- function(jsonparams) {
  if (file.exists(jsonparams)){
    tryCatch(lp <-  jsonlite::fromJSON(jsonparams),
             error = function(c) {
               c$message <- paste0(c$message, " (in ", jsonparams, ")")
               stop(c)
             }
    )
  } else {
    message <- paste0("Parameter file '", jsonparams, "' not found.")
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



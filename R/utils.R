#' Read a JSON file
#'
#' This file has parameters to create a  \code{rug} visualization plot.
#'
#' @param jsonparams Character, a \code{rug} JSON file which can be created using the
#' \code{create_rugjson(...)} function
#' @param visplot Character, a kind of visualization plot. Run \code{list_rugplots()}
#' to see the available plots in \code{rugplot}
#' @param cds_package The package that contains a JSON schema used to validate the JSON file
#'
#' @return A list of parameters to create \code{rugplot} visualization
#'
#' @export
read_rugjson <- function(jsonparams, visplot, cds_package = "rugplot"){

  # JSON schema filename
  jsonschema <- jschema(visplot = visplot)
  schemafile <- system.file("extdata", jsonschema, package = cds_package)
  message("Schema filename: ",schemafile)
  jsonvalidate::json_validate(jsonparams,schemafile,verbose=TRUE,error=TRUE)
  validate_json_file(jsonparams)
}

#' Display help to fill in the `rug` JSON template
#'
#' Display detailed information about the `rug` parameters
#'
#' @param visplot character, run \code{list_rugplots()} to see the available \code{rug} plots
#'
# #' @return
#' @export
#'
# #' @examples
display_rughelp <- function(visplot){
  # JSON schema filename
  jsonschema <- jschema(visplot = visplot)
  rugutils::display_schema(jsonschema)
  message("\nInformation about each of the possible parameters for a '",visplot,"' rugplot is displayed above.",
          "\nIf you need additional details, based on the kind of plot, consult the appropriate ggplot documentation.")
}

#' This function validates a json structure
#'
#' @param jsonparams Character, a JSON object file name to be validated
#'
#' @return An R list of parameters extracted from the JSON object
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

# "@stephenhay"' regex from
# <https://mathiasbynens.be/demo/url-regex>
is_url <- function(string) {
  any(grepl("(https?|ftp)://[^\\s/$.?#].[^\\s]*", string))
}



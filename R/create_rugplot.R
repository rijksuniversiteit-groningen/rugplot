#' Create a \code{rug} visualization plot
#'
#' @param lp List of \code{rug} parameters containing information to create the plot
#' @param visplot A \code{rug} plot
#' @param verbose Additional information
#'
#' @return A ggplot object
#' @export
#'
# #' @examples
create_rugplot <- function(lp, visplot, verbose=TRUE) {
  funcs <- ls("package:rugplot")
  functie <- funcs[endsWith(funcs,visplot)]
  source_rug_plot <- paste0(functie,"(lp, verbose = ",as.character(verbose),")")
  eval(parse(text = source_rug_plot))
}

# Get the available visualization plots in the rugplot package
# rug_plotsdic <- function(){
#   listschemas <- rugplot::vschemas()
#   plots_dic <- c()
#   for (jsonschema in listschemas) {
#     key <- regmatches(jsonschema, regexpr("^[^_]*", jsonschema))
#     plots_dic[key] <- jsonschema
#   }
#   plots_dic
# }

#' Create a \code{rug} visualization plot
#'
#' Create visualization plot using a list of parameters created by the function \code{read_rugjson()}
#'
#' @param lp List of \code{rug} parameters containing information to create the plot
#' @param visplot character, run \code{list_rugplots()} to see the available \code{rug} plots
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

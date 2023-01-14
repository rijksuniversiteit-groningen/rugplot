#' Histogram
#'
#' Creates a ggplot histogram
#'
#' @param lp a list of parameters created from a JSON file
#'
#' "filename": <string, required>
#'
#' "variables": <array, strings representing column names>
#'
#' "y_variable": <string, required variable to be plotted on the vertical direction>
#'
#' "group": <string, a column variable>
#'
#' "colour": <string, a column variable or a predefined color in colors()>
#'
#' "fill": <string, a column variable>
#'
#' "facet_row": <string, a variable name>
#'
#' "facet_column": <string, variable name>
#'
#' "alpha": <number, between 0 and 1>
#'
#' "title": <string, title of the plot>
#'
#' "caption": <string, caption of the plot>
#'
#' "rotxlabs": <number, rotate x labels in grades>
#'
#' "save": <object, composed of 'save', 'height', 'width' and 'device'>
#'
#' "save": <boolean, save the file?
#'
#' "height": <number, in cm of the output visualization file>
#'
#' "width": <number, in cm of the output visualization file>
#'
#' "device": <enum, ["eps", "ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "svg"]>
#'
#' "interactive": <boolean, save Interactive version>
#'
#' Further information can be found in [geom_histogram](https://ggplot2.tidyverse.org/reference/geom_histogram.html).
#' To validate the JSON object use "histogram_schema.json" when calling the `validate_parameters` function.
#'
#' @return a ggplot object and if indicated in 'lp' stores the plot in a file (s)
#' @export
#'
# #' @examples
c_histogram <- function(lp){

  cat("\nCreating the histogram ...\n")

  cols <- rutils::read_data(lp$filename,lp$variables)

  list_factors <- select_factors(cols)
  cat("Categorical columns:",list_factors,"\n")

  list_numeric <- select_numeric(cols)
  cat("Numeric columns:",list_numeric,"\n")

  if (! lp$y_variable %in% colnames(cols) ) {
    stop(paste("'",lp$y_variable,"' must be a column in",lp$filename))
  }

  p <- paste("ggplot2::ggplot(cols, ggplot2::aes(",
            "x = lp$y_variable",
            if (!is.null(lp$colour) && lp$colour %in% list_factors)
              ", color = lp$colour, fill = lp$colour",
            ")) +\n  ggplot2::geom_histogram(",
            add_attributes(lp),
            ") +\n  ggplot2::theme_bw() +\n  ",
            "ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))",
            sep =""
            )
  if (!is.null(lp$labels))
    p <- add_labels(p,lp$labels)

  p <- add_facets(p,lp,list_factors)

  if (!is.null(lp$rotxlabs))
    p <- paste(p,
               " + ggplot2::theme(\n    ",
               "axis.text.x = ggplot2::element_text(angle = lp$rotxlabs, hjust = 1))\n")

  p <- replace_vars(p,lp)
  p <- stringr::str_replace_all(p, ",\n    \\)", "\n  \\)")
  cat(p,"\n")
  p <- eval(parse(text = p))

  if (!is.null(lp$save))
      save_plot(lp,p,"-hist-")
  p
}


#' Histogram
#'
#' Creates a ggplot histogram
#'
#' @param lp a list of parameters created using the `validate_json_file` function
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

  cat("Creating the histogram ...\n")

  cols <- rutils::read_data(lp$filename,lp$variables)

  str(cols)
  list_factors <- select_factors(cols)
  cat("Categorical columns:",list_factors,"\n")

  list_numeric <- select_numeric(cols)
  cat("Numeric columns:",list_numeric,"\n")

  if (! lp$y_variable %in% colnames(cols) ) {
    stop(paste("'",lp$y_variable,"' must be a column in",lp$filename))
  }

  p <- paste(
    "ggplot2::ggplot(cols, ggplot2::aes(","x = lp$y_variable ",
    if (!is.null(lp$colour) && lp$colour %in% list_factors)
      ", color = lp$colour, fill = lp$colour",
    ")) + ggplot2::geom_histogram(",
    if (!is.null(lp$fill))
      if (! lp$fill %in% list_factors)
        "fill = 'lp$fill', ",
    if (!is.null(lp$colour))
      if (! lp$colour %in% list_factors)
        "colour = 'lp$colour', ",
    if (!is.null(lp$position))
      "position = lp$position, ",
    if (!is.null(lp$alpha))
      "alpha = lp$alpha, ",
    if (!is.null(lp$linetype))
      "linetype = lp$linetype, ",
    if (!is.null(lp$size))
      "size = lp$size, ",
    if (!is.null(lp$weight))
      "width = lp$weight",
    ") + ggplot2::theme_bw() + ",
    "ggplot2::labs(",
    if (!is.null(lp$title))
      "title = 'lp$title'",
    if (!is.null(lp$caption))
      ", caption = 'lp$caption'",
    ") + ",
    "ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))",
    sep =""
    )

  p <- add_facets(p,lp,list_factors)

  if (!is.null(lp$rotxlabs))
    p <- paste(p,
               " + ggplot2::theme(\n    ",
               "axis.text.x = ggplot2::element_text(angle = lp$rotxlabs, hjust = 1))\n")

  p <- stringr::str_replace_all(
    p,
    c("lp\\$y_variable" = lp$y_variable,
      "lp\\$colour" = as.character(lp$colour),
      "lp\\$bin_width" = as.character(lp$bin_width),
      "lp\\$alpha" = as.character(lp$alpha),
      "lp\\$title" = as.character(lp$title),
      "lp\\$caption" = as.character(lp$caption)
      )
    )
  p <- stringr::str_replace_all(p, ",\n    \\)", "\n  \\)")
  cat(p,"\n")
  p <- eval(parse(text = p))

  now <- Sys.time()
  if (!is.null(lp$save) && lp$save$save == TRUE){
    outputfile <- file.path(paste0(lp$filename,"-hist-",format(now, "%Y%m%d_%H%M%S"),".",lp$save$device))
    ggplot2::ggsave(outputfile,plot=p, device= lp$save$device,  width = lp$save$width,
                    height =lp$save$height, units = "cm")
    cat(paste("Histogram saved in: ",outputfile),"\n")
  }
  if (!is.null(lp$interactive) && lp$interactive == TRUE) {
    cat("Creating interactive plot ...\n")
    outputfile <- file.path(paste0(lp$filename,"-hist-",format(now, "%Y%m%d_%H%M%S"),".html"))
    ip <- plotly::ggplotly(p)
    htmlwidgets::saveWidget(ip, outputfile)
    print(paste("Interactive plot created:",outputfile))
  }
  p
}


hist_params <- function(){
  json_params <- '{
    "filename": "<path/filename>",
    "variables": [],
    "y-variable": "<varname>",
    "group": "<vargroup>",
    "colour": "black",
    "fill": "lightblue",
    "facet_row": "no-groups",
    "facet_column": "no-groups",
    "bin_width": -1,
    "alpha": 0.5,
	  "height": 10,
	  "width": 15,
	  "title": "Title",
	  "caption":"Caption",
    "save": false,
    "device":"pdf",
    "interactive":false
  }'

  djson <- jsonlite::prettify(json_params)
  djson
}

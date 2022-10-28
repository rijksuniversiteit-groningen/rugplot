#' Violin plots
#'
#' Creates violin plot(s) using ggplot
#'
#' @param lparams a list of parameters created using the `validate_json_file` function
#'
#' "filename": <string, required>
#'
#' "variables": <array, column names to be loaded>
#'
#' "y_variable": <string, required variable to be plotted on the vertical direction>
#'
#' "x_variable: <string, preferable a categorical variable>
#'
#' "factorx": <boolean, whether to convert x_variable into a categorical variable>
#'
#' "position" : <enum, ["dodge", "identity", "dodge2"]>
#'
#' "group": <string, column variable>
#'
#' "colour": <string, a column variable or a predefined color in colors()>
#'
#' "fill": <string, column variable>
#'
#' "linetype": <enum, ["blank", "solid", "dashed", "dotted", "dotdash", "longdash", "twodash"]>
#'
#' "size": <number, line size>
#'
#' "weight": <number, but no used yet>
#'
#' "facet_row": <string, variable name>
#'
#' "facet_column": <string, variable name>
#'
#' "alpha": <number, between 0 and 1>
#'
#' "color_manual": <object, composed of 'values', 'breaks' and 'labels'. See ggplot scale_color_manual documentation.
#'
#'     "values": <array, color values>
#'
#'     "breaks": <array, string of breaks>
#'
#'     "labels": <array, labels(must be same length as breaks)>
#'
#' "boxplot": <object, composed of 'addboxplot' and 'width'>
#'
#'    "addboxplot": <boolean, add box plot>
#'
#'    "width": <number, width of the boxplot>
#'
#' "title": <string, title of thehttps://github.com/badges/shields/issues/7583 plot>
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
#' Further information can be found in \href{https://ggplot2.tidyverse.org/reference/geom_violin.html}{geom_violin} documentation.
#' To validate the JSON object use "violin_schema.json" when calling the `validate_parameters` function.
#'
#' @return a ggplot object and if indicated in 'lparams' stores the plot in a file (s)
#' @export
#'
# #' @examples

c_violin <- function(lparams) {

  dt <- read_data(lparams$filename,lparams$variables)
  # factor variables
  fnames <- select_factors(dt)
  # numeric variables
  nnames <- select_numeric(dt)

  varnames <- colnames(dt)

  if (! lparams$y_variable %in% varnames)
    stop(paste("'",lparams$y_variable,"' must be a column in the file",lparams$filename))

  xvar <- "''"
  if (!is.null(lparams$x_variable) && lparams$x_variable %in% varnames)
    if (lparams$x_variable %in% fnames)
      xvar <- lparams$x_variable
    else if (lparams$factorx == TRUE)
      xvar <- "as.factor(lparams$x_variable)"

  p <- paste(
    "ggplot2::ggplot(dt, ggplot2::aes(","x = xvar, y = lparams$y_variable ",
    if (!is.null(lparams$fill))
      if (lparams$fill %in% fnames)
        ",fill = lparams$fill",
    if (!is.null(lparams$colour))
      if (lparams$colour %in% fnames)
        ", colour = lparams$colour",
    ")) + ggplot2::geom_violin(",
    if (!is.null(lparams$fill))
      if (! lparams$fill %in% fnames)
        "fill = 'lparams$fill', ",
    if (!is.null(lparams$colour))
      if (! lparams$colour %in% fnames)
        "colour = 'lparams$colour', ",
    if (!is.null(lparams$position))
      "position = 'lparams$position', ",
    if (!is.null(lparams$alpha))
      "alpha = lparams$alpha, ",
    if (!is.null(lparams$linetype))
      "linetype = 'lparams$linetype', ",
    if (!is.null(lparams$size))
      "size = lparams$size, ",
    if (!is.null(lparams$weight))
      "width = lparams$weight",
    ") + ",
    "ggplot2::theme_bw() +",
    "ggplot2::labs(",
    if (!is.null(lparams$title))
      "title = 'lparams$title'",
    if (!is.null(lparams$caption))
      ", caption = 'lparams$caption'",
    ") + ",
    "ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))",
    sep =""
   )

  p <- add_facets(p,lparams,fnames)

  if (!is.null(lparams$rotxlabs))
    p <- paste(p,
      " + ggplot2::theme(\n    ",
        "axis.text.x = ggplot2::element_text(angle = lparams$rotxlabs, hjust = 1))\n")

  p <- stringr::str_replace_all(
    p,
    c("lparams\\$y_variable" = lparams$y_variable,
      "xvar" = as.character(xvar),
      "lparams\\$colour" = as.character(lparams$colour),
      "lparams\\$fill" = as.character(lparams$fill),
      "lparams\\$alpha" = as.character(lparams$alpha),
      "lparams\\$linetype" = as.character(lparams$linetype),
      "lparams\\$position" = as.character(lparams$position),
      "lparams\\$size" = as.character(lparams$size),
      "lparams\\$weight" = as.character(lparams$weight),
      "lparams\\$alpha" = as.character(lparams$alpha),
      "lparams\\$title" = as.character(lparams$title),
      "lparams\\$caption" = as.character(lparams$caption)
    )
  )
  p <- stringr::str_replace_all(p, ",\n    \\)", "\n  \\)")
  cat(p,"\n")
  p <- eval(parse(text = p))

  # manual color
  if (!is.null(lparams$color_manual)) {
    vals <- lparams$color_manual$values
    cat("colors:",vals,"\n")
    p <- p + ggplot2::scale_color_manual(values = vals,
                                        breaks = NULL)
    p <- p + ggplot2::scale_fill_manual(values = vals,
                                         breaks = lparams$color_manual$breaks,
                                        labels = lparams$color_manual$labels)
  }

  if (!is.null(lparams$boxplot) && lparams$boxplot$addboxplot == TRUE){
    if (!is.null(lparams$boxplot$width)){
      cat(paste("Adding boxplots: \n width:",lparams$boxplot$width),"\n")
      p <- p + ggplot2::geom_boxplot(colour="#636363", width = lparams$boxplot$width,alpha=0.2)
    } else {
      p <- p + ggplot2::geom_boxplot(colour="#636363", width = 0.1,alpha=0.2)
    }
  }
  now <- Sys.time()
  if (!is.null(lparams$save) && lparams$save$save == TRUE){
    cat("Creating plot ...","\n")
    outputfile <- file.path(paste0(lparams$filename,"-violin-",format(now, "%Y%m%d_%H%M%S"),".",lparams$save$device))
    ggplot2::ggsave(outputfile,plot=p, device= lparams$save$device,  width = lparams$save$width,
                    height =lparams$save$height, units = "cm")
    cat(paste("Plot saved in: ",outputfile),"\n")
  }
  if (!is.null(lparams$interactive) && lparams$interactive == TRUE) {
    cat("Creating interactive plot ...","\n")
    outputfile <- file.path(paste0(lparams$filename,"-violin-",format(now, "%Y%m%d_%H%M%S"),".html"))
    ip <- plotly::ggplotly(p,width=800,height=600)
    htmlwidgets::saveWidget(ip, outputfile)
    cat(paste("Interactive plot in: ",outputfile),"\n")
  }
  cat(paste0("Object '",class(p)[2],"' successfully created"),"\n")
  return(p)
}

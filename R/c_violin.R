#' Violin plots
#'
#' Creates violin plot(s) using ggplot
#'
#' @param lp a list of parameters created using the `validate_json_file` function
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
#' @return a ggplot object and if indicated in 'lp' stores the plot in a file (s)
#' @export
#'
# #' @examples

c_violin <- function(lp) {

  dt <- rutils::read_data(lp$filename,lp$variables)
  # factor variables
  fnames <- select_factors(dt)
  # numeric variables
  nnames <- select_numeric(dt)

  varnames <- colnames(dt)

  if (! lp$y_variable %in% varnames)
    stop(paste("'",lp$y_variable,"' must be a column in the file",lp$filename))

  xvar <- "''"
  if (!is.null(lp$x_variable) && lp$x_variable %in% varnames)
    if (lp$x_variable %in% fnames)
      xvar <- lp$x_variable
    else if (lp$factorx == TRUE)
      xvar <- "as.factor(lp$x_variable)"

  p <- paste(
    "ggplot2::ggplot(dt, ggplot2::aes(","x = lp$x_variable, y = lp$y_variable",
    if (!is.null(lp$fill))
      if (lp$fill %in% fnames)
        ",fill = lp$fill",
    if (!is.null(lp$colour))
      if (lp$colour %in% fnames)
        ", colour = lp$colour",
    ")) +\n  ggplot2::geom_violin(",
    add_attributes(lp),
    ") +\n",
    "  ggplot2::theme_bw() +\n",
    "  ggplot2::labs(",
    if (!is.null(lp$title))
      "title = 'lp$title'",
    if (!is.null(lp$caption))
      ", caption = 'lp$caption'",
    ") +\n",
    "  ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +\n",
    sep =""
   )

  p <- add_facets(p,lp,fnames)

  if (!is.null(lp$rotxlabs))
    p <- paste(p,
      "  ggplot2::theme(\n    ",
        "axis.text.x = ggplot2::element_text(angle = lp$rotxlabs, hjust = 1))\n",sep="")

  # particular case for the x_variable
  p <- stringr::str_replace_all(p,c("lp\\$x_variable" = as.character(xvar)))
  p <- replace_vars(p,lp)

  cat(p,"\n")
  # p <- stringr::str_replace_all(p, ",\n    \\)", "  \\)")
  p <- eval(parse(text = p))

  # manual color
  if (!is.null(lp$color_manual)) {
    vals <- lp$color_manual$values
    cat("colors:",vals,"\n")
    p <- p + ggplot2::scale_color_manual(values = vals,
                                        breaks = NULL)
    p <- p + ggplot2::scale_fill_manual(values = vals,
                                         breaks = lp$color_manual$breaks,
                                        labels = lp$color_manual$labels)
  }

  if (!is.null(lp$boxplot) && lp$boxplot$addboxplot == TRUE){
    if (!is.null(lp$boxplot$width)){
      cat(paste("Adding boxplots: \n width:",lp$boxplot$width),"\n")
      p <- p + ggplot2::geom_boxplot(colour="#636363", width = lp$boxplot$width,alpha=0.2)
    } else {
      p <- p + ggplot2::geom_boxplot(colour="#636363", width = 0.1,alpha=0.2)
    }
  }
  now <- Sys.time()
  if (!is.null(lp$save) && lp$save$save == TRUE){
    cat("Creating plot ...","\n")
    outputfile <- file.path(paste0(lp$filename,"-violin-",format(now, "%Y%m%d_%H%M%S"),".",lp$save$device))
    ggplot2::ggsave(outputfile,plot=p, device= lp$save$device,  width = lp$save$width,
                    height =lp$save$height, units = "cm")
    cat(paste("Plot saved in: ",outputfile),"\n")
  }
  if (!is.null(lp$interactive) && lp$interactive == TRUE) {
    cat("Creating interactive plot ...","\n")
    outputfile <- file.path(paste0(lp$filename,"-violin-",format(now, "%Y%m%d_%H%M%S"),".html"))
    ip <- plotly::ggplotly(p,width=800,height=600)
    htmlwidgets::saveWidget(ip, outputfile)
    cat(paste("Interactive plot in: ",outputfile),"\n")
  }
  cat(paste0("Object '",class(p)[2],"' successfully created"),"\n")
  return(p)
}

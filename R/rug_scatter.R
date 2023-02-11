#' Scatter plot
#'
#' @param lp List of parameters including information to create a scatter plot. The list
#' is created using the function \code{read_rugjson()}
#' @param verbose Additional information
#'
#' @return A ggplot object
#' @export
#'
#' @keywords internal
#'
# #' @examples
rug_scatter <- function(lp, verbose = TRUE) {

  message("Creating the scatter plot ...")

  dt <- rugutils::read_data(lp$filename,lp$variables)
  # factor variables
  fnames <- select_factors(dt)
  # numeric variables
  nnames <- select_numeric(dt)

  varnames <- colnames(dt)

  p <- paste(
    "ggplot2::ggplot(dt, ggplot2::aes(",
    add_aesthetics(lp$aesthetics,varnames),
    ")) +\n  ggplot2::geom_point(",
    add_attributes(lp),
    ") +\n",
    "  ggplot2::theme_bw() +\n",
    "  ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)",
    ")",
    if (!is.null(lp$theme$legend$key$size))
      " +\n\tggplot2::guides(color = ggplot2::guide_legend(override.aes = list(size = lp$theme$legend$key$size)))"
    ,
    sep =""
  )

  if (!is.null(lp$labels))
    p <- add_labels(p,lp$labels)

  p <- add_facets(p,lp,fnames)

  if (!is.null(lp$rotxlabs))
    p <- paste(p,
               " +\n  ggplot2::theme(\n    ",
               "axis.text.x = ggplot2::element_text(angle = lp$rotxlabs, hjust = 1))\n",sep="")

  p <- replace_vars(p,lp)

  if (verbose)
    message(p)
  # p <- stringr::str_replace_all(p, ",\n    \\)", "  \\)")
  p <- eval(parse(text = p))

  # manual color
  if (!is.null(lp$color_manual)) {
    vals <- lp$color_manual$values
    if (verbose)
      message(paste("colors:",vals))
    if (!is.null(vals)) {
      p <- p + ggplot2::scale_color_manual(values = vals,
                                           breaks = NULL)

      p <- p + ggplot2::scale_fill_manual(values = vals,
                                          breaks = lp$color_manual$breaks,
                                          labels = lp$color_manual$labels)
    }
  }

  if (!is.null(lp$boxplot) && lp$boxplot$addboxplot == TRUE){
    if (!is.null(lp$boxplot$width)){
      if (verbose)
        message(paste("Adding boxplots: \n width:",lp$boxplot$width),"\n")
      p <- p + ggplot2::geom_boxplot(colour="#636363", width = lp$boxplot$width,alpha=0.2)
    } else {
      p <- p + ggplot2::geom_boxplot(colour="#636363", width = 0.1,alpha=0.2)
    }
  }

  if (!is.null(lp$save))
    save_plot(lp,p,"-violin-",verbose=verbose)

  message("Violin plot visualization done.")
  p
}

#' Violin plots
#'
#' \code{rug_violin} is a reusable function that saves violin plots in different file formats (image, pdf, interactive html).
#'
#' One of the best ways to run \code{rug_violin} is as follows:
#' \enumerate{
#' \item Create a JSON parameters file using the \code{create_json} function.
#' \item Open the JSON file and fill in the required parameters.
#'       \itemize{
#'           \item Required parameters are in angle brackets.
#'           \item For details of the parameters run \code{rutils::display_schema("violin_schema.json")}.
#'           \item Customize the rest of the pairs as needed.
#'           \item A file name is automatically generated, If no output file name is provided.
#'       }
#' \item Create and validate the list \code{lp} using  \code{validate_json_file} function.
#' \item Just in case, validate your JSON parameters file against the violin schema using the \code{validate_parameters} function.
#' \item Run the \code{rug_violin} function.
#' }
#'
#' @param lp a list of parameters created from a JSON file
#'
#' @return A ggplot object and might save the violin plot in a file.
#' @export
#'
#' @examples
#' # Assuming that your data file is 'iris.csv'
#' \dontrun{
#' # Step 1
#' create_json("violin_schema.json")
#' # By default "violin_params.json" will be generated in the current directory.
#'
#' # Step 2
#' # Open "violin_params.json" in your favorite editor, replace and save the following
#' # "<filename path>" by "iris.csv"
#' # "<Y required column name>" by "sepal_length", make sure the column name is correct
#' # and replace '"x_variable": null' to '"X_variable": "species"'
#'
#' # Step 3
#' lp <- rutils::validate_json_file("violin_params.json")
#'
#' # Step 4
#' rutils::validate_parameters("violin_params.json","violin_schema.json")
#'
#' # Step 5
#' rug_violin(lp)
#' # As a result, a similar 'iris.csv-violin-220118_121703.213.pdf' file will be created
#' }
#'

rug_violin <- function(lp) {

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
    "  ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))",
    sep =""
   )

  if (!is.null(lp$labels))
    p <- add_labels(p,lp$labels)

  p <- add_facets(p,lp,fnames)

  if (!is.null(lp$rotxlabs))
    p <- paste(p,
      " +\n  ggplot2::theme(\n    ",
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

  if (!is.null(lp$save))
    save_plot(lp,p,"-violin-")

  return(p)
}

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
#' @param lp a list of parameters created from a JSON file.
#'
#' @param verbose Boolean to print extended information.
#'
#' @return A ggplot object and if requested it will save the violin plot in a file.
#' @export
#'
#' @keywords internal
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

rug_violin <- function(lp, verbose = TRUE) {

  message("Creating the visualization ...")

  dt <- rugutils::read_data(lp$filename,lp$variables)
  # factor variables
  fnames <- select_factors(dt)
  # numeric variables
  nnames <- select_numeric(dt)

  varnames <- colnames(dt)

  p <- paste(
    "ggplot2::ggplot(dt, ggplot2::aes(",
    add_aesthetics(lp$aesthetics,varnames),
    ")) +\n  ggplot2::geom_violin(",
    add_attributes(lp$attributes),
    ")",
    # TODO: the following 8 lines of code
    if (is.null(lp$axes_scales$y_discrete$labels))
      "+\n\tggplot2::scale_y_discrete(labels = NULL)"
    else if (lp$axes_scales$y_discrete$labels[1] != 'waiver()')
      add_scales_discrete(lp$axes_scales$y_discrete$labels,"y")
    ,
    if (is.null(lp$axes_scales$x_discrete$labels))
      "+\n\tggplot2::scale_x_discrete(labels = NULL)"
    else if (lp$axes_scales$x_discrete$labels[1] != 'waiver()')
      add_scales_discrete(lp$axes_scales$x_discrete$labels,"x")
    ,
    "+\n\tggplot2::theme_bw() +\n",
    "  ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))",
    sep =""
   )

  if (!is.null(lp$labels))
    p <- add_labels(p,lp$labels)

  p <- add_facets(p,lp$facets,fnames)

  if (!is.null(lp$attributes$rotxlabs))
    p <- paste(p,
      " +\n  ggplot2::theme(\n    ",
        "axis.text.x = ggplot2::element_text(angle = lp$attributes$rotxlabs, hjust = 1))\n",sep="")

  p <- replace_vars(p,lp)

  if (verbose)
    message(p)
  # p <- stringr::str_replace_all(p, ",\n    \\)", "  \\)")
  p <- eval(parse(text = p))

  # manual color
  vals <- lp$color_manual$values
  # TODO: verify that the length of breaks, labels and values are correct
  if (!is.null(lp$color_manual) & length(vals) > 0) {
    if (verbose)
      message(paste("colors:",vals))
    if (!is.null(vals)) {
      p <- p + ggplot2::scale_color_manual(values = vals,
                                           breaks = lp$color_manual$breaks,
                                           labels = lp$color_manual$labels,
                                           aesthetics = c("colour", "fill"))

      # p <- p + ggplot2::scale_fill_manual(values = vals,
      #                                    breaks = lp$color_manual$breaks,
      #                                   labels = lp$color_manual$labels)
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

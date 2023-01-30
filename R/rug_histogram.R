#' Histogram
#'
#' \code{rug_histogram} is a reusable function that saves histograms in different file formats (image, pdf, interactive html).
#'
#' One of the best ways to create the list of parameters \code{lp} is as follows:
#' \enumerate{
#' \item Create a JSON parameters file using the \code{create_json} function.
#' \item Open the JSON file and fill in the required parameters.
#'       \itemize{
#'           \item Required parameters are in angle brackets.
#'           \item For details of the parameters run \code{rutils::display_schema("histogram_schema.json")}.
#'           \item Customize the rest of the pairs as needed.
#'           \item A file name is automatically generated, If no output file name is provided.
#'       }
#' \item Create and validate the list \code{lp} using  \code{validate_json_file} function.
#' \item Just in case, validate your JSON parameters file against the histogram schema using the \code{validate_parameters} function.
#' \item Run the \code{rug_histogram} function.
#' }
#'
#' @param lp a list of parameters created from a JSON file.
#'
#' @param verbose Boolean to print extended information.
#'
#' @return A ggplot object and could save the histogram in a file.
#' @export
#' @keywords internal
#' @examples
#' # Assuming that your data file is 'iris.csv'
#' \dontrun{
#' # Step 1
#' create_json("histogram_schema.json")
#' # By default "histogram_params.json" will be generated in the current directory.
#'
#' # Step 2
#' # Open "histogram_params.json" in your favorite editor, replace and save the following
#' # "<filename path>" by "iris.csv"
#' # "<required column name>" by "sepal_length", make sure the column name is correct
#' # and change '"save": false' to '"save": true'
#'
#' # Step 3
#' lp <- rutils::validate_json_file("histogram_params.json")
#'
#' # Step 4
#' rutils::validate_parameters("histogram_params.json","histogram_schema.json")
#'
#' # Step 5
#' rug_histogram(lp)
#' # As a result, a similar 'iris.csv-hist-220118_121703.213.pdf' file will be created
#' }
#'
rug_histogram <- function(lp, verbose = TRUE){

  cat("\nCreating the histogram ...\n")

  cols <- rugutils::read_data(lp$filename,lp$variables)

  list_factors <- select_factors(cols)
  if (verbose)
    message(paste("Categorical columns:",list_factors))

  list_numeric <- select_numeric(cols)

  if (verbose)
    message(paste("Numeric columns:",list_numeric,"\n"))

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

  if (verbose)
    message(p)
  p <- eval(parse(text = p))

  if (!is.null(lp$save))
      save_plot(lp,p,"-hist-",verbose=verbose)

  message("Visualization histogram done.")
  p
}


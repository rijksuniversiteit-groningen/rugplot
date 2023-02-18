#' PCA projection
#'
#' \code{rug_pca} is a function that creates a projection based on Principal Component Analysis
#'
#' One of the best ways to run \code{rug_pcaproj} is as follows:
#' \enumerate{
#' \item Create a JSON parameters file using the \code{create_json} function.
#' \item Open the JSON file and fill in the required parameters.
#'       \itemize{
#'           \item Required parameters are in angle brackets.
#'           \item For details of the parameters run \code{rutils::display_schema("pca_projection_schema.json")}.
#'           \item Customize the rest of the pairs as needed.
#'           \item A file name is automatically generated, If no output file name is provided.
#'       }
#' \item Create and validate the list \code{lp} using  \code{validate_json_file} function.
#' \item Just in case, validate your JSON parameters file against the violin schema using the \code{validate_parameters} function.
#' \item Run the \code{rug_pca} function.
#' }
#'
#' @param lp A list of parameters created from a JSON file.
#'
#' @param verbose Boolean to print extended information.
#'
#' @return A ggplot object and if requested it will save the projection plot in a file.
#' @export
#'
#' @keywords internal
#'
#' @examples
#'
#' # Assuming that your data file is 'iris.csv'
#' \dontrun{
#' # Step 1
#' create_json("pca_projection_schema.json")
#' # By default "pca_projection_params.json" will be generated in the current directory.
#'
#' # Step 2
#' # Open "pca_projection_params.json" in your favorite editor, replace and save the following
#' # "<filename path>" by "iris.csv" and the name/pair
#' # '"colour": null' by '"colour": "species"', make sure the column name 'species' is correct.
#'
#' # Step 3
#' lp <- rutils::validate_json_file("pca_projection_params.json")
#'
#' # Step 4
#' rutils::validate_parameters("pca_projection_params.json","pca_projection_schema.json")
#'
#' # Step 5
#' rug_pca(lp)
#' # As a result, a similar 'iris.csv-pca-220118_121703.213.pdf' file will be created.
#' }
#'
rug_pca <- function(lp, verbose = TRUE){

  message("Creating the PCA projection ...")

  cols <- rugutils::read_data(lp$filename,lp$variables)

  pcacols <- colnames(cols)

  if (!iscolor(lp$colour) && !(lp$colour %in% pcacols)){
    warning(paste0("'",lp$colour,"' is not a colour nor column name of the file."))
    lp$colour <- NULL
  }

  if (verbose)
    message(str(cols))

  pcacols <- pcacols[! pcacols %in% append(c(),lp$colour)]

  if (verbose)
    message(pcacols)
  # PCA
  tpca <- stats::prcomp(na.omit(Filter(is.numeric,dplyr::select(cols,all_of(pcacols)))),
                        scale=lp$scale)

  if (verbose)
    message(summary(tpca))
  # load `.__T__[:base` to fix `! Objects of type prcomp not supported by autoplot.`
  ggfortify::`.__T__[:base`

  p <- paste("ggplot2::autoplot(tpca, data = cols, colour = 'lp$colour',
                         loadings = lp$biplot, loadings.colour = 'black',
                         loadings.label = lp$biplot,
                         loadings.label.colour = 'black',
                         loadings.label.size = 4) +\n  ",
                         "ggplot2::theme_bw() +\n  ",
                         "ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))",
             sep = "")

  if (!is.null(lp$labels))
    p <- add_labels(p,lp$labels)

  p <- replace_vars(p,lp)

  if (verbose)
    message(p)

  p <- eval(parse(text = p))

  if (!is.null(lp$save))
    save_plot(lp,p,"-pca-",verbose=verbose)

  message("PCA projection done.")
  p
}


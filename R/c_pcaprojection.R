
#' PCA projection
#'
#' Projection based on Principal Component Analysis
#'
#' @param lp a list of parameters created using the `validate_json_file` function
#'
#' "filename": <string, required data file including more than 3 columns>
#'
#' "variables": <array, numeric columns for applying PCA>
#'
#' "colour": <string, categorical variable to colour the projected points>
#'
#' "scale": <boolean, required whether to scale the selected variables>
#'
#' "biplot": <boolean, Display biplot (loadings)>
#'
#' "title": <string, title of the plot>
#'
#' "caption": <string, caption of the plot>
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

#' "interactive": <boolean, save interactive html version>
#'
#' To validate the JSON object use "pca_projection_schema.json" when calling the `validate_parameters` function.
#'
#' @return a ggplot object
#' @export
#'
# #' @examples
c_pcaproj <- function(lp){

  cat("Print creating the PCA projection ...")
  colorear <- lp$colour

  if (colorear == ""){
    colorear = NULL
  }

  pscale <- lp$scale
  pbiplot <- lp$biplot
  pcacols <- lp$variables

  if (length(lp$variables) < 1)
    colvars <- NULL
  else
    colvars <- lp$variables

  cols <- rutils::read_data(lp$filename,colvars)

  pcacols <- colnames(cols)
  cat(str(cols))
  pcacols <- pcacols[! pcacols %in% append(c(),colorear)]

  cat(paste0(pcacols),"\n")
  # PCA
  tpca <- stats::prcomp(Filter(is.numeric,dplyr::select(cols,all_of(pcacols))),scale=pscale)

  print(summary(tpca))
  # load `.__T__[:base` to fix `! Objects of type prcomp not supported by autoplot.`
  ggfortify::`.__T__[:base`
  p <- ggplot2::autoplot(tpca, data = cols, colour = colorear,
                         loadings = pbiplot, loadings.colour = 'black',
                         loadings.label = pbiplot,
                         loadings.label.colour = 'black',
                         loadings.label.size = 4) + ggplot2::theme_bw()
  p <- p + ggplot2::labs(title = lp$title,caption = lp$caption)
  p <- p + ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
  now <- Sys.time()
  if (!is.null(lp$save) && lp$save$save == TRUE){
    cat("Creating plot ...","\n")
    outputfile <- file.path(paste0(lp$filename,"-pca-",format(now, "%Y%m%d_%H%M%S"),".",lp$save$device))
    ggplot2::ggsave(outputfile,plot=p, device= lp$save$device,  width = lp$save$width,
                    height =lp$save$height, units = "cm")
    cat(paste("Projection saved in: ",outputfile))
  }
  if (!is.null(lp$interactive) && lp$interactive == TRUE) {
    cat("Creating interactive plot ...")
    outputfile <- file.path(paste0(lp$filename,"-pca-",format(now, "%Y%m%d_%H%M%S"),".html"))
    ip <- plotly::ggplotly(p)
    htmlwidgets::saveWidget(ip, outputfile)
    cat(paste("Interactive PCA plot in: ",outputfile))
  }
  p
}

pca_params <- function(json_schema){
  # json_params <- '{
  #   "filename": "<path/filename>",
  #   "col_ids": ["<var1>","<var2>","<...>","<varN>"],
  #   "colour": "<categorical varX>",
  #   "scale": true,
  #   "biplot": true,
  #   "height": 10,
  #   "width": 15,
  #   "title": "<MyTitle>",
  #   "caption": "<MyCaption>",
  #   "save": false,
  #   "device": "<pdf>",
  #   "interactive":true
  # }'

  djson <- jsonlite::prettify(json_params)
  djson
}

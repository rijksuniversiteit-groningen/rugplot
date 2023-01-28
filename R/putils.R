iscolor <- function(lcols) {
  sapply(lcols, function(scol) {
    tryCatch(is.matrix(grDevices::col2rgb(scol)),
             error = function(e) FALSE)
  })
}


add_facets <- function(splot,lpars,factornames){

  if (!is.null(lpars$facet_row))
    if (lpars$facet_row %in% factornames)
      facets <- paste(lpars$facet_row,"~")
  else {
    warning(paste("Facet row: column",lpars$facet_row,
                  "not in the list of factors",factornames))
    facets <- ". ~"
  }
  else
    facets <- ". ~"

  if (!is.null(lpars$facet_colum))
    if (lpars$facet_colum %in% factornames)
      facets <- paste(facets,lpars$facet_column)
  else {
    facets <- paste(facets,".")
    warning("Facet column: column", lpars$facet_column,
                  "not in the list of factors",factornames)
  }
  else
    facets <- paste(facets,".")

  message("Facets: ",facets)
  if (facets != ". ~ .")
    splot <- paste(splot, "+ ggplot2::facet_grid(", facets, ")")
  splot
}

add_labels <- function(ggsourceplot,labels){
  labs <- paste0(
    if (!is.null(labels$title)) {
      "title = 'lp$labels$title',"
    },
    if (!is.null(labels$subtitle)) {
      "subtitle = 'lp$labels$subtitle',"
    },
    if (!is.null(labels$tag)) {
      "tag = 'lp$labels$tag',"
    },
    if (!is.null(labels$x)) {
      "x = 'lp$labels$x',"
    },
    if (!is.null(labels$y)) {
      "y = 'lp$labels$y',"
    },
    if (!is.null(labels$colour)) {
      "colour = 'lp$labels$colour',"
    },
    if (!is.null(labels$fill)) {
      "fill = 'lp$labels$fill',"
    },
    if (!is.null(labels$caption)) {
      "caption = 'lp$labels$caption',"
    }
  )
  labs <- gsub('.{1}$', '', labs)

  if (length(labs) > 0)
      ggsourceplot <- paste(ggsourceplot, " +\n  ggplot2::labs(", labs, ")")
  ggsourceplot
}

add_attributes <- function(lparams){
  atts <- paste(
    if (!is.null(lparams$fill) && iscolor(lparams$fill)){
      "fill = 'lp$fill',"
    },
    if (!is.null(lparams$colour) && iscolor(lparams$colour)){
        " colour = 'lp$colour',"
    },
    if (!is.null(lparams$position)){
        " position = 'lp$position',"
    },
    if (!is.null(lparams$alpha)){
        " alpha = lp$alpha,"
    },
    if (!is.null(lparams$linetype)){
        " linetype = 'lp$linetype',"
    },
    if (!is.null(lparams$size)){
        " size = lp$size,"
    },
    if (!is.null(lparams$weight)){
       " width = lp$weight,"
    },
    sep = ""
  )
  atts <- gsub('.{1}$', '', atts)
}

# Replace name of variables by values
replace_vars <- function(ggcode_plot, lparams){
  ggcode_plot <- stringr::str_replace_all(
    ggcode_plot,
    c("lp\\$y_variable" = lparams$y_variable,
      "lp\\$x_variable" = as.character(lparams$x_variable),
      "lp\\$colour" = as.character(lparams$colour),
      "lp\\$fill" = as.character(lparams$fill),
      "lp\\$biplot" = as.character(lparams$biplot),
      "lp\\$alpha" = as.character(lparams$alpha),
      "lp\\$linetype" = as.character(lparams$linetype),
      "lp\\$rotxlabs" = as.character(lparams$rotxlabs),
      "lp\\$position" = as.character(lparams$position),
      "lp\\$size" = as.character(lparams$size),
      "lp\\$weight" = as.character(lparams$weight),
      "lp\\$alpha" = as.character(lparams$alpha),
      "lp\\$labels\\$title" = lparams$labels$title,
      "lp\\$labels\\$subtitle" = as.character(lparams$labels$subtitle),
      "lp\\$labels\\$tag" = as.character(lparams$labels$tag),
      "lp\\$labels\\$x" = as.character(lparams$labels$x),
      "lp\\$labels\\$y" = as.character(lparams$labels$y),
      "lp\\$labels\\$colour" = as.character(lparams$labels$colour),
      "lp\\$labels\\$fill" = as.character(lparams$labels$fill),
      "lp\\$labels\\$caption" = as.character(lparams$labels$caption)
    )
  )
}

json_defaults <- function(jsonl){
  if (!is.null(jsonl$properties))
    json_defaults(jsonl$properties)
  else {
    property <-""
    for (name in names(jsonl)){
      # print(paste(name,":",class(jsonl[[name]]$default)))
      if (!is.null(jsonl[[name]]$properties))
        property <- paste(property,jsonlite::toJSON(name,auto_unbox = TRUE),":",
                          json_defaults(jsonl[[name]]),",")
      else
        property <- paste(property,jsonlite::toJSON(name,auto_unbox = TRUE),":",
                          jsonlite::toJSON(jsonl[[name]]$default,auto_unbox = TRUE,null = "null"),",")
    }
    return(paste("{",gsub('.{1}$', '', property),"}"))
  }
}

#' JSON schema filenames
#'
#' @return vector of the available \code{rug} JSON schema file names
#' @export
#'
#' @keywords internal
#'
# #' @examples
vschemas <- function(){
  list.files(system.file("extdata",package="rugplot"),pattern = ".*_")
}

#' Create a \code{rug} JSON template file
#'
#' @param visplot character, a \code{rug} plot. Run the \code{list_rugplots()} function to get a list of
#' \code{rug} plots.
#' @param jsonfile character, a JSON filename to store the JSON structure and default parameters.
#' @param overwrite boolean, a flag to overwrite the 'JSON file'.
#' @param package R package to which `visplot` belongs.
#'
#' @return character, name of the created JSON file
#' @export
#'
# #' @examples
create_rugjson <- function(visplot, jsonfile= NULL, overwrite = FALSE, package = 'rugplot'){

  jsonschema <- jschema(visplot = visplot)

  jsfile <- system.file("extdata", jsonschema, package = package)
  jsonlist <- jsonlite::fromJSON(jsfile)

  djs <- json_defaults(jsonlist)
  cat(jsonlite::prettify(djs))
  if (is.null(jsonfile))
    jsonfile <- gsub('schema', 'params', jsonschema, fixed=TRUE)

  if (!file.exists(jsonfile) || overwrite)
  {
    write(jsonlite::prettify(djs),jsonfile)
    message("'",jsonfile,"' template successfully created.\nFill in the template to continue.")
  }
  else {
    warning("The file '",jsonfile,"' already exists.\n",
              "Set the 'overwrite' parameter to TRUE or provide a different filename\n")
  }
  jsonfile
}

#' Valid `rug` plot
#'
#' @param visplot  A `rug` plot.
#'
#' Verify that `visplot` is a valid `rug` plot. Run \code{list_rugplots()} to see valid `rug` plots.
#'
#' @return Character, a JSON schema file name
#' @export
#'
#' @keywords internal
#'
# #' @examples
jschema <- function(visplot){
  rug_plots_list <- dic_rugplots()

  if (!visplot %in% names(rug_plots_list) )
    stop("Type error: '", visplot, "' is not a rugplot!")
  else
    jsonschema <- rug_plots_list[visplot]
}

#' List the available \code{rug} plots
#'
#' @return Character vector including the available `rug` plots
#' @export
#'
# #' @examples
list_rugplots <- function(){
  names(dic_rugplots())
}


#' Get a list of available \code{rug}/JSONschema pairs
#'
#' @return vector
#' @export
#' @keywords internal
# #' @examples
dic_rugplots <- function(){
  listschemas <- rugplot::vschemas()
  plots_dic <- c()
  for (jsonschema in listschemas) {
    key <- regmatches(jsonschema, regexpr("^[^_]*", jsonschema))
    plots_dic[key] <- jsonschema
  }
  plots_dic
}

save_plot <- function(lparams, myplot, suffix = ""){
  ldevice = lparams$save$device
  tk <- FALSE
  if (ldevice == 'tikz') {
    ldevice <- 'pdf'
    tk <- TRUE
  }
  if (lparams$save$save == TRUE){
    if (!is.null(lparams$save$outputfilename)){
        outputfile <- lparams$save$outputfilename
        if(endsWith(outputfile, paste0(".",ldevice)))
          outputfile <- substr(outputfile,1,nchar(outputfile)- nchar(ldevice) - 1)
    }
    else {
      if (is_url(lparams$filename))
        outputfile <- file.path(paste0(sub('.*/', '', lparams$filename),
                                       suffix,format(Sys.time(), "%Y%m%d_%H%M%OS3")))
      else
        outputfile <- file.path(paste0(lparams$filename,suffix,
                                     format(Sys.time(), "%Y%m%d_%H%M%OS3")))
    }

    if (file.exists(paste0(outputfile,".",ldevice)) && !lparams$save$overwrite)
      outputfile <- file.path(paste0(outputfile,
                                     suffix,
                                     format(Sys.time(), "%Y%m%d_%H%M%OS3")))

    outputfile <- paste0(outputfile,".",ldevice)
    if (ldevice == "html"){
      ip <- plotly::ggplotly(myplot,
                               width = lparams$save$width * 37.8,
                               height = lparams$save$height * 37.8 )
      htmlwidgets::saveWidget(ip, outputfile)
    }
    else if (tk) {
      td <- tempdir()
      oldwd <- getwd()
      tempfile <- file.path(td,'tmpplot.tex')

      cmwidth <- lparams$save$width/2.54
      cmheight <- lparams$save$height/2.54
      setwd(td)
      tikzDevice::tikz(tempfile,standAlone=TRUE,sanitize = lparams$save$sanitize,width = cmwidth,
                       height = cmheight, verbose = TRUE)
      print(myplot)
      dev.off()
      ofile <- tinytex::pdflatex(tempfile)
      if (file.exists(ofile)){
        message("pdf file created", ofile)
        file.copy(from = ofile, to = file.path(oldwd,outputfile))
      }
      setwd(oldwd)
    } else{
      ggplot2::ggsave(outputfile,
                    plot=myplot,
                    device= ldevice,
                    width = lparams$save$width,
                    height = lparams$save$height,
                    dpi = lparams$save$dpi,
                    units = "cm")
    }
    # TODO: consider the tikz case
    message("Plot saved in: ",outputfile,"\n")
  }
}

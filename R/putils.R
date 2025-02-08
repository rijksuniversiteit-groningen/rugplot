iscolor <- function(lcols) {
  sapply(lcols, function(scol) {
    tryCatch(is.matrix(grDevices::col2rgb(scol)),
             error = function(e) FALSE)
  })
}

add_fill_gradient <- function(fill_gradient){

  pal <- fill_gradient$colours$palette
  scalevals <- ""
  scalevals <- paste(scalevals," +\n\tggplot2::scale_fill_",
        fill_gradient$method,"(",
        if (fill_gradient$method == "gradientn")
        {
          paste0("colors = hcl.colors(lp$colour_scales$fill_gradient$colours$n",
                 if (!pal %in% hcl.pals()){
                   warning("Palette '",pal,"' not found, using 'viridis' instead")
                 }
                 else
                   ", palette = 'lp$colour_scales$fill_gradient$colours$palette'"
                 ,
                 "),"
          )
        }
        else {
          lmh <- ""
          if (!is.null(fill_gradient$low))
              if (iscolor(fill_gradient$low))
                lmh <- paste0(lmh,"low = 'lp$colour_scales$fill_gradient$low',")
              else
                warning("'",fill_gradient$low,"' is not a color, using default instead")

          if (fill_gradient$method == "gradient2")
            if (!is.null(fill_gradient$mid))
              if (iscolor(fill_gradient$mid))
                lmh <- paste0(lmh," mid = 'lp$colour_scales$fill_gradient$mid',")
              else
                warning("'",fill_gradient$mid,"' is not a color, using default instead")

          if (!is.null(fill_gradient$high))
            if (iscolor(fill_gradient$high))
              lmh <- paste0(lmh," high = 'lp$colour_scales$fill_gradient$high',")
            else
              warning("'",fill_gradient$high,"' is not a color, using default instead")
        },

        if (!is.null(fill_gradient$na.value))
            if (iscolor(fill_gradient$na.value))
              " na.value = 'lp$colour_scales$fill_gradient$na.value',"
            else
              warning("'",fill_gradient$na.value,"' is not a color, using default instead")
        ,
        if (!is.null(fill_gradient$na.guide))
          " guide = 'lp$colour_scales$fill_gradient$guide',"
        ,
        sep=""
        )
  if (length(scalevals) > 1)
    scalevals <- gsub('.{1}$', '', scalevals)

  scalevals <- paste0(scalevals,")")
}

# add quotes to discrete labels/breaks
addquotes <- function(ss) {
  # paste(sQuote(stringr::str_trim(stringr::str_split(ss,"=")[[1]],
  #                                side="both")), collapse = " = ")
  paste(paste0("'",stringr::str_trim(stringr::str_split(ss,"=")[[1]]),"'"),collapse = " = ")
}

add_scales_discrete <- function(labs,eje){

  paste(" +\n\tggplot2::scale_",eje,"_discrete(labels = c(",
        paste(sapply(labs,addquotes),collapse = ', ')
    ,
    "))",
    sep = ""
  )
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

add_aesthetics <- function(aesvars, columnnames){
  aesstr <- paste(
    if (! aesvars$x_variable %in% columnnames && !aesvars$x_variable == "''")
      stop(paste("'",aesvars$x_variable,"' must be a column in the data file"))
    else if (!is.null(aesvars$factorx) && aesvars$factorx == TRUE){
      "x = as.factor(lp$aesthetics$x_variable),"
    } else {
      "x = lp$aesthetics$x_variable,"
    },
    if (!is.null(aesvars$y_variable))
    if (! aesvars$y_variable %in% columnnames)
      stop(paste("'",aesvars$y_variable,"' must be a column in the data file"))
    else
      "y = lp$aesthetics$y_variable,"
    ,
    if (!is.null(aesvars$fill))
      if (!aesvars$fill %in% columnnames)
        stop(paste("'",aesvars$fill,"' must be a column in the data file"))
      else
        "fill = lp$aesthetics$fill,"
    ,
    if (!is.null(aesvars$alpha))
        if (! aesvars$alpha %in% columnnames)
          warning("Aesthetics alpha'", aesvars$alpha,"' ignored because column name not found")
        else
          " alpha = lp$aesthetics$alpha,"
    ,
    if (!is.null(aesvars$colour))
        if (! aesvars$colour %in% columnnames)
          warning("Aesthetics colour'", aesvars$colour,"' ignored because column name not found")
        else
          " colour = lp$aesthetics$colour,"
    ,
    if (!is.null(aesvars$linetype))
      if (! aesvars$linetype %in% columnnames)
        warning("Aesthetics linetype'", aesvars$linetype,"' ignored because column name not found")
      else
        " linetype = lp$aesthetics$linetype,"
    ,
    if (!is.null(aesvars$shape))
      if (! aesvars$shape %in% columnnames)
        warning("Aesthetics shape '", aesvars$shape,"' ignored because column name not found")
      else {
        " shape = lp$aesthetics$shape,"
      },
    if (!is.null(aesvars$size))
      if (! aesvars$size %in% columnnames)
        warning("Aesthetics size '", aesvars$size,"' ignored because column name not found")
      else {
        " size = lp$aesthetics$size,"
      },
    if (!is.null(aesvars$width))
      if (! aesvars$width %in% columnnames)
        warning("Aesthetics width '", aesvars$width,"' ignored because column name not found")
      else {
        " width = lp$aesthetics$width,"
      },
    if (!is.null(aesvars$stroke))
      if (! aesvars$stroke %in% columnnames)
        warning("Aesthetics stroke '", aesvars$stroke,"' ignored because column name not found")
      else {
        " stroke = lp$aesthetics$stroke,"
      },
    if (!is.null(aesvars$weight))
      if (! aesvars$weight %in% columnnames)
        warning("Aesthetics weight '", aesvars$weight,"' ignored because column name not found")
      else {
        " weight = lp$aesthetics$weight,"
      },
    if (!is.null(aesvars$group))
      if (! aesvars$group %in% columnnames)
        warning("Aesthetics group '", aesvars$group,"' ignored because column name not found")
      else {
        " group = lp$aesthetics$group,"
      },
    sep = ""
  )
  aesstr <- gsub('.{1}$', '', aesstr)
}

add_attributes <- function(lparams){
  atts <- paste(
    if (!is.null(lparams$fill) && iscolor(lparams$fill)){
      "fill = 'lp$attributes$fill',"
    },
    if (!is.null(lparams$colour) && iscolor(lparams$colour)){
        " colour = 'lp$attributes$colour',"
    },
    if (!is.null(lparams$position)){
        " position = 'lp$attributes$position',"
    },
    if (!is.null(lparams$alpha)){
        " alpha = lp$attributes$alpha,"
    },
    if (!is.null(lparams$linetype)){
        " linetype = 'lp$attributes$linetype',"
    },
    if (!is.null(lparams$width)){
      " linewidth = 'lp$attributes$width',"
    },
    if (!is.null(lparams$shape))
        if (lparams$shape %in% shape_names)
            " shape = 'lp$attributes$shape',"
        else if (is.numeric(lparams$shape)){
            " shape = lp$attributes$shape,"
        } else if (length(lparams$shape)==1)
          " shape = 'lp$attributes$shape',"
    ,
    if (!is.null(lparams$size)){
        " size = lp$attributes$size,"
    },
    if (!is.null(lparams$stroke)){
      " stroke = lp$attributes$stroke,"
    },
    if (!is.null(lparams$weight)){
       " width = lp$attributes$weight,"
    },
    if (!is.null(lparams$trim)){
      " trim = lp$attributes$trim,"
    },
    if (!is.null(lparams$scale)){
      " scale = lp$attributes$scale,"
    },
    if (!is.null(lparams$interpolate)){
      " interpolate = lp$attributes$interpolate,"
    },
    if (!is.null(lparams$orientation)){
      " orientation = lp$attributes$orientation,"
    },
    sep = ""
  )
  atts <- gsub('.{1}$', '', atts)
}

# Replace name of variables by values
replace_vars <- function(ggcode_plot, lparams){
  ggcode_plot <- stringr::str_replace_all(
    ggcode_plot,
    c("lp\\$aesthetics\\$y_variable" = lparams$aesthetics$y_variable,
      "lp\\$aesthetics\\$x_variable" = as.character(lparams$aesthetics$x_variable),
      "lp\\$aesthetics\\$fill" = as.character(lparams$aesthetics$fill),
      "lp\\$aesthetics\\$colour" = as.character(lparams$aesthetics$colour),
      "lp\\$aesthetics\\$alpha" = as.character(lparams$aesthetics$alpha),
      "lp\\$aesthetics\\$linetype" = as.character(lparams$aesthetics$linetype),
      "lp\\$aesthetics\\$linewidth" = as.character(lparams$aesthetics$linewidth),
      "lp\\$aesthetics\\$shape" = as.character(lparams$aesthetics$shape),
      "lp\\$aesthetics\\$size" = as.character(lparams$aesthetics$size),
      "lp\\$aesthetics\\$stroke" = as.character(lparams$aesthetics$stroke),
      "lp\\$aesthetics\\$width" = as.character(lparams$aesthetics$width),
      "lp\\$aesthetics\\$group" = as.character(lparams$aesthetics$group),
      "lp\\$aesthetics\\$weight" = as.character(lparams$aesthetics$weight),
      "lp\\$attributes\\$colour" = as.character(lparams$colour),
      "lp\\$attributes\\$fill" = as.character(lparams$fill),
      "lp\\$biplot" = as.character(lparams$biplot),
      "lp\\$attributes\\$alpha" = as.character(lparams$attributes$alpha),
      "lp\\$attributes\\$linetype" = as.character(lparams$attributes$linetype),
      "lp\\$attributes\\$rotxlabs" = as.character(lparams$attributes$rotxlabs),
      "lp\\$attributes\\$position" = as.character(lparams$attributes$position),
      "lp\\$attributes\\$size" = as.character(lparams$attributes$size),
      "lp\\$attributes\\$weight" = as.character(lparams$attributes$weight),
      "lp\\$attributes\\$alpha" = as.character(lparams$attributes$alpha),
      "lp\\$attributes\\$stroke" = as.character(lparams$attributes$stroke),
      "lp\\$attributes\\$shape" = as.character(lparams$attributes$shape),
      "lp\\$attributes\\$trim" = as.character(lparams$attributes$trim),
      "lp\\$attributes\\$scale" = as.character(lparams$attributes$scale),
      "lp\\$attributes\\$interpolate" = as.character(lparams$attributes$interpolate),
      "lp\\$attributes\\$orientation" = as.character(lparams$attributes$orientation),
      "lp\\$labels\\$title" = lparams$labels$title,
      "lp\\$labels\\$subtitle" = as.character(lparams$labels$subtitle),
      "lp\\$labels\\$tag" = as.character(lparams$labels$tag),
      "lp\\$labels\\$x" = as.character(lparams$labels$x),
      "lp\\$labels\\$y" = as.character(lparams$labels$y),
      "lp\\$labels\\$colour" = as.character(lparams$labels$colour),
      "lp\\$labels\\$fill" = as.character(lparams$labels$fill),
      "lp\\$labels\\$caption" = as.character(lparams$labels$caption),
      "lp\\$theme\\$legend\\$key\\$size" = as.character(lparams$theme$legend$key$size),
      "lp\\$colour_scales\\$fill_gradient\\$low" = as.character(lparams$colour_scales$fill_gradient$low),
      "lp\\$colour_scales\\$fill_gradient\\$mid" = as.character(lparams$colour_scales$fill_gradient$mid),
      "lp\\$colour_scales\\$fill_gradient\\$high" = as.character(lparams$colour_scales$fill_gradient$high),
      "lp\\$colour_scales\\$fill_gradient\\$na.value" = as.character(lparams$colour_scales$fill_gradient$na.value),
      "lp\\$colour_scales\\$fill_gradient\\$guide" = as.character(lparams$colour_scales$fill_gradient$guide),
      "lp\\$colour_scales\\$fill_gradient\\$colours\\$n" = as.character(lparams$colour_scales$fill_gradient$colours$n),
      "lp\\$colour_scales\\$fill_gradient\\$colours\\$palette" = as.character(lparams$colour_scales$fill_gradient$colours$palette)
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

#' Create a \code{rugplot} JSON template file
#'
#' This file contains the default and required parameters to create a visualization plot
#' using the \code{rugplot} package. The required parameters must be provided by the user.
#'
#' @param visplot Character, a kind of visualization supported by \code{rug plot}. Run the
#' \code{list_rugplots()} function to get a list of available visualizations.
#' @param jsonfile Character, a JSON filename to store the JSON structure and default parameters.
#' @param overwrite Boolean, a flag to overwrite the 'JSON file'.
#' @param package R package that contains the JSON schema to validate the JSON file.
#'
#' @return Character, name of the created JSON file
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
  return(jsonfile)
}

#' JSON schema for a visualization plot
#'
#' @param visplot
#'
#' @return string jsonschema
#' @export
#'
# #' @examples
rug_jsonschema <- function(visplot){
  jschemafilename <- jschema(visplot)

  jsfile <- system.file("extdata", jschemafilename, package = 'rugplot')
  strschema <- readLines(jsfile)
  # return(jsonlite::prettify(strschema))
  return(strschema)
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

save_plot <- function(lparams, myplot, suffix = "",verbose = FALSE){
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
      message("Creating the LaTeX file")
      td <- tempdir()
      oldwd <- getwd()
      tempfile <- file.path(td,'tmpplot.tex')

      cmwidth <- lparams$save$width/2.54
      cmheight <- lparams$save$height/2.54

      setwd(td)
      tryCatch({
        # options(tikzLatex = "/home/rstudio/bin/lualatex")
        # options(tikzDefaultEngine="luatex")

        options(tikzDocumentDeclaration = "\\documentclass[tikz,crop=true]{standalone}")

        tikzDevice::tikz(tempfile,standAlone=TRUE,sanitize = lparams$save$sanitize,width = cmwidth,
                       height = cmheight, engine = "luatex", verbose = verbose)
          print(myplot)
        dev.off()

        if (nzchar(Sys.which("lualatex"))) {
          ofile <- system(paste("lualatex", tempfile), intern = TRUE)
        } else if (tinytex::is_tinytex()) {
          ofile <- tinytex::lualatex(tempfile)
        } else {
          stop("No LaTeX installation found. Please install TeX Live or TinyTeX.")
        }
        
        if (file.exists(ofile)){
          message(ofile, " created using lualatex.")
          file.copy(from = ofile, to = file.path(oldwd,outputfile), overwrite = lparams$save$overwrite)
        }
        setwd(oldwd)
      },
      error = function(c) {
        c$message <- paste0(c$message, "\nTikZ plot not created. Returning to working directory '",
                            oldwd,"'")
        setwd(oldwd)
        stop(c)
      }
      )

    } else{
      ggplot2::ggsave(outputfile,
                    plot=myplot,
                    device= ldevice,
                    width = lparams$save$width,
                    height = lparams$save$height,
                    dpi = lparams$save$dpi,
                    units = "cm")
    }
    message("Plot saved in: ",outputfile,"\n")
  }
}

shape_names <- c(
  "circle", paste("circle", c("open", "filled", "cross", "plus", "small")), "bullet",
  "square", paste("square", c("open", "filled", "cross", "plus", "triangle")),
  "diamond", paste("diamond", c("open", "filled", "plus")),
  "triangle", paste("triangle", c("open", "filled", "square")),
  paste("triangle down", c("open", "filled")),
  "plus", "cross", "asterisk"
)

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
    warning(paste("Facet column: column", lpars$facet_column,
                  "not in the list of factors",factornames))
  }
  else
    facets <- paste(facets,".")

  cat(paste("Facets:",facets),"\n")
  if (facets != ". ~ .")
    splot <- paste(splot, "+ ggplot2::facet_grid(", facets, ")")
  splot
}


add_attributes <- function(lparams){
  need_comma <- FALSE
  paste(
    if (!is.null(lparams$fill) && iscolor(lparams$fill)){
      need_comma <- TRUE
      "fill = 'lp$fill'"
    },
    if (!is.null(lparams$colour) && iscolor(lparams$colour)){
      if (need_comma)
        ", colour = 'lp$colour'"
      else{
        need_comma <- TRUE
        "colour = 'lp$colour'"
      }
    },
    if (!is.null(lparams$position)){
      if (need_comma)
        ", position = 'lp$position'"
      else{
        need_comma <- TRUE
        "position = 'lp$position'"
      }
    },
    if (!is.null(lparams$alpha)){
      if (need_comma)
        ", alpha = lp$alpha"
      else{
        need_comma <- TRUE
        "alpha = lp$alpha"
      }
    },
    if (!is.null(lparams$linetype)){
      if (need_comma)
        ", linetype = 'lp$linetype'"
      else{
        need_comma <- TRUE
        "linetype = 'lp$linetype'"
      }
    },
    if (!is.null(lparams$size)){
      if (need_comma)
        ", size = lp$size"
      else{
        need_comma <- TRUE
        "size = lp$size"
      }
    },
    if (!is.null(lparams$weight)){
      if (need_comma)
       ", width = lp$weight"
      else
        "width = lp$weight"
    }
  )
}

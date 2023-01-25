wide2long <- function(parametersfile){
  if (file.exists(parametersfile)){
    tryCatch(lp <- jsonlite::fromJSON(parametersfile),
             error = function(c) {
               c$message <- paste0(c$message, " (in ", parametersfile, ")")
               stop(c)
             }
    )
  } else {
    message <- paste0("Parameter file '", parametersfile, "' not found.")
    stop(message)
  }

  print(lp)

  res <- validate_parameters(parametersfile,"wide2long_schema.json")

  if (res==FALSE) {
    stop("The json parameters file does not meet the schema")
  }

  print(lp$col_ids)
  print(length(lp$col_ids))

  if (!length(lp$col_ids) > 0){
    lp$col_ids <- NULL
  }

  tryCatch(cols <- data.table::fread(lp$filename,select = lp$col_ids),
           error = function(c) {
             c$message <- paste0(c$message, " (in ", parametersfile, ")")
             stop(c)
           }
  )

  print(str(cols))

  DT = data.table::melt(cols, id.vars = lp$idvars,measure.vars = lp$measure.vars)
  print(DT)

  if (lp$save == TRUE) {
    print("Saving file ...")
    now <- Sys.time()
    outputfile <- file.path(paste0(lp$filename,"-long-",
                                   format(now, "%Y%m%d_%H%M%S"),".csv"))
    data.table::fwrite(DT,outputfile)
    print(paste("Projection saved in: ",outputfile))
  }
}

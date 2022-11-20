#' ZIP for targets framework
#'
#' Wraps the zip::zip function for use in the targets context. Implements a non-functional ellipsis to add custom dependencies.
#'
#' @param x Character. The files to be added to the ZIP archive.
#' @param filename Character. The name of the final ZIP archive.
#' @param dir Character. The directory in which to create the ZIP archive.
#' @param mode Character. The mode to be used. Can be "mirror" or "cherry-pick".
#'
#' @return Character. The path to the ZIP file.

f.tar_zip <- function(x,
                      filename,
                      dir,
                      mode = "mirror",
                      ...){
    
    
    filename <- file.path(dir, filename)
    
    zip::zip(filename,
             x,
             mode = mode)
    
    return(filename)
    
}



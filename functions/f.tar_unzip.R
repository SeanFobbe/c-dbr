

#' Function that unzips an arbitrary number of archives with the {zip] package for R and returns the paths to unzipped files as a character vector.
#'
#' @param zipfiles The archives zo be unzipped.
#' @param exdir The target directory for unzipped files.
#'
#'
#' @return A character vector of paths to unzipped files..



f.tar_unzip <- function(zipfiles,
                        exdir){

    dir.create(exdir, showWarnings = FALSE)

    sapply(zipfiles, zip::unzip, exdir = exdir)

    content.list <- lapply(zipfiles, zip::zip_list)

    content.vec <- data.table::rbindlist(content.list)$filename
    content.vec <- file.path(exdir, content.vec)

    return(content.vec)
    

}

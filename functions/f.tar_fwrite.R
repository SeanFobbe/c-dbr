#' fwrite for targets workflows

#' Wraps the data.table::fwrite function for use in the targets context. Mainly necessary to return the file name for later tracking.
#'
#' @param x Data.table to be written to disk.
#' @param filename Character. Filename of the CSV file.
#'
#' @param return Character. Filename of the CSV file on disk.



f.tar_fwrite <- function(x,
                         filename){


    data.table::fwrite(x,
                       file = filename,
                       na = "NA")

    return(filename)
    
}

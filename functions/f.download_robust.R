
#' Wrapper function for download.file that returns 'NA' instead of an error when a file is not available.
#'
#' @param url A valid URL.
#' @param destile The destination file.
#'




f.download_robust <- function(url,
                              destfile){

    tryCatch({download.file(url = url,
                            destfile = destfile)
    },
    error = function(cond) {
        return(NA)}

    )

}

#' Download large number of files
#'
#' Downloads a large number of files with a wide range of options, including custom sleep times, custom retries, custom sleep during retries, timeout and a debug toggle for testing a reduced number of files. Will check the filenames in the destination folder to ensure that only files scheduled to be downloaded are present. Will skip already downloaded files.


#' @param url Character. A vector of URLS.
#' @param filename Character. A vector of filenames.
#' @param dir Character. The destination directory. Will be created if not already present.
#' @param clean Logical. Clean folder of all files that are not on the download list?
#' @param sleep.min Positive Integer. Minimum number of seconds to randomly sleep between requests.
#' @param sleep.max Positive Integer. Maximum number of seconds to randomly sleep between requests.
#' @param retries Positive Integer. Number of retries for entire download set.
#' @param retry.sleep.min Positive Integer. Minimum number of seconds to randomly sleep between requests in retry mode.
#' @param retry.sleep.max Positive Integer. Maximum number of seconds to randomly sleep between requests in retry mode.
#' @param random.order Logical. Whether to download files in random order. Defaults to TRUE.
#' @param timeout Positive Integer. Number of seconds for a download to timeout, even active ongoing ones.
#' @param debug.toggle Logical. Whether to activate debugging mode.
#' @param debug.files Positive Integer. The number of files to download during debugging mode. Default is 500.

#' @return Character. A vector of the downloaded file names.


f.download <- function(url,
                       filename,
                       dir,
                       clean = TRUE,
                       multicore = FALSE,
                       cores = parallel::detectCores(),
                       sleep.min = 0,
                       sleep.max = 0.1,
                       retries = 3,
                       retry.sleep.min = 2,
                       retry.sleep.max = 5,
                       random.order = FALSE,
                       timeout = 300,
                       debug.toggle = FALSE,
                       debug.files = 500){



    if(multicore == TRUE){

        future::plan("multicore",
                     workers = cores)

        sleep.min  <- 0
        sleep.max  <- 0
        
    }else{

        future::plan("sequential")

    }

    
    ## Set timeout for downloads
    options(timeout = timeout)

    
    
    ## Test for equality of length
    if(length(url) != length(filename)){

        stop("Length of arguments 'url' and 'filename' is not equal.")
        
    }

    
    ## Create download folder
    dir.create(dir, showWarnings = FALSE, recursive = TRUE)


    
    ## Create data frame
    df <- data.frame(url, filename)


    ## [Debugging Mode] Reduce download scope
    if (debug.toggle == TRUE){

        sample.index <- sort(sample(nrow(df), debug.files))
        df <- df[sample.index,]

    }

    
    ## Clean folder: Only files included in 'filename' may be present

    if (clean == TRUE){
    
        files.all <- list.files(dir, full.names = TRUE)
        delete <- setdiff(files.all, file.path(dir, df$filename))
        unlink(delete)

    }


    
    ## Exclude already downloaded files
    
    files.present <- list.files(dir)
    filename.todo <- setdiff(df$filename, files.present)
    df.todo  <- df[df$filename %in% filename.todo,]
    df.todo <- df.todo[!is.na(df.todo$url),] # skip NA urls

    
    
    ## Download: First Try


    if(nrow(df.todo) > 0){
        
        if(random.order == TRUE){
            
            df.todo <- df.todo[sample(nrow(df.todo)),]

        }
        
        result.todo <- future_mapply(f.download_robust,
                                     url = df.todo$url,
                                     destfile = file.path(dir, df.todo$filename),
                                     sleep.min = sleep.min,
                                     sleep.max = sleep.max,
                                     future.seed = TRUE)

    }
    


    ## Download: Retries

    for(i in 1:retries){
        
        ## Missing files
        
        files.present <- list.files(dir)
        filename.missing <- setdiff(df$filename, files.present)
        df.missing  <- df[df$filename %in% filename.missing,]
        df.missing <- df.missing[!is.na(df.missing$url),] # skip NA urls


        if(nrow(df.missing) > 0){
            
            if(random.order == TRUE){
                
                df.missing <- df.todo[sample(nrow(df.missing)),]

            }
            
            result.retry <- future_mapply(f.download_robust,
                                          url = df.missing$url,
                                          destfile = file.path(dir, df.missing$filename),
                                          sleep.min = retry.sleep.min,
                                          sleep.max = retry.sleep.max,
                                          future.seed = TRUE)

        }

    }
    



    ## Report Missing Files
    
    if(length(filename.missing) > 0){

        warning(paste("Missing file:", filename.missing, collapse = "\n"))
        
    }


    
    ## Final File Count
    
    files.all <- list.files(dir, full.names = TRUE)
    message(paste("Downloaded", length(files.all), "of", length(filename), "files."))


    return(files.all)
    
}







#' Wrapper function for download.file that returns 'NA' instead of an error when a file is not available.
#'
#' @param url A valid URL.
#' @param destfile The destination file.
#' @param sleep.min Positive Integer. Minimum number of seconds to randomly sleep between requests.
#' @param sleep.max Positive Integer. Maximum number of seconds to randomly sleep between requests.
#'
#' @return Character. Returns destination file invisibly.




f.download_robust <- function(url,
                              destfile,
                              sleep.min = 0,
                              sleep.max = 0){

    tryCatch({download.file(url = url,
                            destfile = destfile)
    },
    error = function(cond) {
        return(NA)}

    )

    Sys.sleep(runif(1, sleep.min, sleep.max))

    invisible(destfile)

}

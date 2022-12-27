#' Computation of SHA2 and SHA3 Hashes

#' Computes SHA2-256 and SHA3-512 hashes for a single file. It returns a data frame with the file name, SHA2-256 hashe and SHA3-512 hash.  The function requires the existence of the openssl (RPM) library on the system.


#' @param x Path to file.


#+
#'## Required: OpenSSL System Library
#' The function requires the existence of the openssl (RPM) library on the system.


f.multihashes <- function(x){
    sha2.256 <- system2("openssl",
                        paste("sha256",
                              x),
                        stdout = TRUE)
    
    sha2.256 <- gsub("^.*\\= ",
                     "",
                     sha2.256)
    
    sha3.512 <- system2("openssl",
                        paste("sha3-512",
                              x),
                        stdout = TRUE)
    
    sha3.512 <- gsub("^.*\\= ",
                     "",
                     sha3.512)
    
    hashes <- data.frame(x,
                         sha2.256,
                         sha3.512)
    return(hashes)
}





#' Parallel Computation of SHA2 and SHA3 Hashes

#' This function parallelizes computation of both SHA2-256 and SHA3-512 hashes for an arbitrary number of files. It returns a data frame of file names, SHA2-256 hashes and SHA3-512 hashes. The function requires the existence of the openssl library (RPM) on the system.
#'
#' Please note that you must declare your own future evaluation strategy prior to using the function to enable parallelization. By default the function will be evaluated sequentially. On Windows, use future::plan(multisession, workers = n), on Linux/Mac, use future::plan(multicore, workers = n), where n stands for the number of CPU cores you wish to use. Due to the need to read/write to the disk the function may not work properly on high-performance clusters.


#' @param x A vector of filenames. Should be located in the working directory.




f.future_multihashes <- function(x){
    
    ## Timestamp: Begin
    begin <- Sys.time()

    ## Intro Message
    message(paste("Processing",
                  length(x),
                  "files. Begin at:",
                  begin))
    
    ## Compute Hashes
    hashes.list <- future.apply::future_lapply(x,
                                               f.multihashes)

    ## Coerce List to data.table
    hashes.table <- data.table::rbindlist(hashes.list)

    ## Coerce data.table to data.frame
    data.table::setDF(hashes.table)

    ## Timestamp: End
    end <- Sys.time()

    ## Duration
    duration <- end - begin


    ## Result Message
    message(paste0("Processed ",
                  length(x),
                  " files. Runtime was ",
                  round(duration,
                        digits = 2),
                  " ",
                  attributes(duration)$units,
                  "."))
    
    return(hashes.table)
    
}


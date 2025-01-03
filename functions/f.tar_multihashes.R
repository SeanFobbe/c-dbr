#' Parallel Computation of SHA2 and SHA3 Hashes

#' This function parallelizes computation of both SHA2-256 and SHA3-512 hashes for an arbitrary number of files. The function requires the system "openssl" library.

#' @param x Character. A vector of filenames.
#' @param multicore Logical. Whether to parallelize the computations.
#' @param cores Integer. Number of cores to use for parallel computation.
#'
#' @param return Data.table. Index, file names, SHA2-256 hashes and SHA3-512 hashes.



f.tar_multihashes <- function(x,
                              multicore = TRUE,
                              cores = 2){


    ## Parallel Computing Settings
    if(multicore == TRUE){

        plan("multicore",
             workers = cores)
        
    }else{

        plan("sequential")

    }

    
    ## Calculate Hashes
    multihashes <- f.future_multihashes(x)

    ## Set names
    setnames(multihashes,
             old = "x",
             new = "filename")


    #'## Add Index
    multihashes$index <- seq_len(multihashes[,.N])
    

    return(multihashes)
    
}






#' Parallel Computation of SHA2 and SHA3 Hashes

#' This function parallelizes computation of both SHA2-256 and SHA3-512 hashes for an arbitrary number of files. It returns a data frame of file names, SHA2-256 hashes and SHA3-512 hashes. The function requires the existence of the openssl library (RPM) on the system.
#'
#' Please note that you must declare your own future evaluation strategy prior to using the function to enable parallelization. By default the function will be evaluated sequentially. On Windows, use future::plan(multisession, workers = n), on Linux/Mac, use future::plan(multicore, workers = n), where n stands for the number of CPU cores you wish to use.
#'
#' Due to the need to read from the disk this function may not work properly on high-performance clusters.


#' @param x Character. A vector of filenames or paths.
#' @param quiet Logical. Whether to print length, begin, end and duration.



f.future_multihashes <- function(x,
                                 quiet = TRUE){
    
    ## Timestamp: Begin
    begin <- Sys.time()

    ## Intro Message
    if (quiet == FALSE){
    message(paste("Processing",
                  length(x),
                  "files. Begin at:",
                  begin))
    }
    
    ## Compute Hashes
    hashes.list <- future.apply::future_lapply(x,
                                               f.multihashes)

    ## Coerce List to data.table
    hashes.table <- data.table::rbindlist(hashes.list)

    ## Timestamp: End
    end <- Sys.time()

    ## Duration
    duration <- end - begin


    ## Result Message
    if (quiet == FALSE){
    message(paste0("Processed ",
                  length(x),
                  " files. Runtime was ",
                  round(duration,
                        digits = 2),
                  " ",
                  attributes(duration)$units,
                  "."))
    }
    
    return(hashes.table)
    
}




#' Computation of SHA2 and SHA3 Hashes

#' Computes SHA2-256 and SHA3-512 hashes for a single file. The function requires the system "openssl" library.


#' @param x Character. A vector of file names or paths to files.
#'
#' @return Data.table. Contains file name and hashes.


#+
#'## Required: OpenSSL System Library
#' The function requires the existence of the "openssl" library on the system.


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
    
    hashes <- data.table::data.table(x,
                                     sha2.256,
                                     sha3.512)
    
    return(hashes)
    
}



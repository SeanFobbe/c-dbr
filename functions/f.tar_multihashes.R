
#' Parallel Computation of SHA2 and SHA3 Hashes

#' This function parallelizes computation of both SHA2-256 and SHA3-512 hashes for an arbitrary number of files. The function requires the existence of the openssl library (RPM) on the system.

#' @param x A vector of filenames.
#' @param multicore Whether to parallelize the computations.
#' @param cores Number of cores to use for parallel computation.
#'
#' @param return A data frame of file names, SHA2-256 hashes and SHA3-512 hashes.



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
    


    
    #'## Transform to data.table
    setDT(multihashes)

    setnames(multihashes,
             old = "x",
             new = "filename")


    #'## Add Index
    multihashes$index <- seq_len(multihashes[,.N])
    

    return(multihashes)
    
}

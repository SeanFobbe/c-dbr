#' High-performance computation of linguistic statistics

#' Iterated parallel computation of characters, tokens, types and sentences for each document of a given data table. Requires f.future_lingsummarize function from the R-fobbe-proto-package. Compatible with targets framework.

#' @param x Data.table. Must contain texts in a "text" variable and document names in a "doc_id" variable.
#' @param multicore Logical. Whether to process each document sequentially or to use multiple cores. Defaults to TRUE.
#' @param cores Positive integer. Number of cores to be used. Defautls to 2.
#' @param germanvars Logical. Whether to return variable names in German. Defaults to FALSE.

#' library(quanteda)
#' library(future)
#' library(future.apply)
#' library(data.table)


f.lingstats <- function(x,
                        multicore = TRUE,
                        cores = 2,
                        germanvars = FALSE,
                        tokens_locale = "en"){

    ## Set Future Strategy
    if(multicore == TRUE){

        plan("multicore",
             workers = cores)
        
    }else{

        plan("sequential")

    }

    ## Set Tokens Locale
    quanteda_options(tokens_locale = tokens_locale)
    

    ## Perform Calculations
    lingstats <- f.future_lingsummarize(x)


    ## Optional: Set German variable names
    if(germanvars == TRUE){

        setnames(lingstats,
                 old = c("nchars",
                         "ntokens",
                         "ntypes",
                         "nsentences"),
                 new = c("zeichen",
                         "tokens",
                         "typen",
                         "saetze"))

    }


    return(lingstats)

    
}

#' Parallel computation of linguistic statistics

#' Iterated parallel computation of characters, tokens, types and sentences for each document of a given data table. Assumes quanteda 4.0.0 or higher. Compatible with targets framework. 

#' @param x Data.table. Must contain texts in a "text" variable and document names in a "doc_id" variable.
#' @param multicore Logical. Whether to process each document sequentially or to use multiple cores. Defaults to TRUE.
#' @param cores Positive integer. Number of cores to be used. Defaults to 2.
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
    lingstats <- f.future_lingsummarize(x, quiet = TRUE)


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



#'# future_lingsummarize
#' Iterated parallel computation of characters, tokens, types and sentences for each document of a given data table. Documents must contain text in a "text" variable and document names in a "doc_id" variable. The functionality is similar to textstats_summary() from the quanteda.textstats package, but this function is optimized for parallel processing of very large corpora.
#'
#' During computation documents are ordered by number of characters (descending) to ensure that long documents are computed first. For corpora with a skewed document length distribution this is significantly faster.


# library(quanteda)
# library(future)
# library(future.apply)


f.future_lingsummarize <- function(dt,
                                   chunksperworker = 1,
                                   chunksize = NULL,
                                   quiet = FALSE){

    begin <- Sys.time()

    dt <- dt[,.(doc_id, text)]
    
    nchars <- nchar(dt$text)

    if(quiet == FALSE){
    
    message(paste0("Processing ",
                 dt[,.N],
                 " documents with a total length of ",
                 format(sum(nchars), big.mark = ","),
                 " characters."))

    }

    
    ord <- order(-nchars)
    dt <- dt[ord]

    raw.list <- split(dt, seq(nrow(dt)))
    
    result.list <- future_lapply(raw.list,
                                 f.lingsummarize,
                                 future.seed = TRUE,
                                 future.scheduling = chunksperworker,
                                 future.chunk.size = chunksize)
    
    result.dt <- rbindlist(result.list)

    
    summary.corpus <- result.dt[order(ord)]


    end <- Sys.time()
    duration <- end - begin


    if(quiet == FALSE){
    
    message(paste0("Runtime was ",
                 round(duration,
                       digits = 2),
                 " ",
                 attributes(duration)$units,
                 ". Ended at ",
                 end, "."))

    }

    if (nrow(dt) != nrow(summary.corpus)){
        stop("Number of input and output rows are unequal.")
    }
    
    return(summary.corpus)

}






f.lingsummarize <- function(dt){

    tryCatch({

        nchars <- nchar(dt$text)
        corpus <- corpus(dt)
        
        tokens.words <- tokens(corpus,
                               what = "word",
                               remove_punct = FALSE,
                               remove_symbols = FALSE,
                               remove_numbers = FALSE,
                               remove_url = FALSE,
                               remove_separators = TRUE,
                               split_hyphens = FALSE,
                               include_docvars = FALSE,
                               padding = FALSE
                               )

        if(unname(lengths(tokens.words)) == 0){

            out <- data.table(nchars,
                              ntokens = 0,
                              ntypes = 0,
                              nsentences = 0)
            
        }else{            

            tokens.sentences <- tokens(corpus,
                                       what = "sentence",
                                       remove_punct = FALSE,
                                       remove_symbols = FALSE,
                                       remove_numbers = FALSE,
                                       remove_url = FALSE,
                                       remove_separators = TRUE,
                                       split_hyphens = FALSE,
                                       include_docvars = FALSE,
                                       padding = FALSE
                                       )
            
            ntokens <- unname(ntoken(tokens.words))
            ntypes  <- unname(ntype(tokens.words))
            nsentences <- unname(lengths(tokens.sentences))

            
            out <- data.table(nchars,
                              ntokens,
                              ntypes,
                              nsentences)

        }
        
        return(out)
        
    },
    error = function(cond) {
        return(data.table(ntokens = NA,
                          ntypes = NA,
                          nsentences = NA))}
    )

    
}


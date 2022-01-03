#'# future_lingsummarize
#' Iterated parallel computation of characters, tokens, types and sentences for each document of a given data table. Documents must contain text in a "text" variable and document names in a "doc_id" variable.
#'
#' During computation documents are ordered by number of characters (descending) to ensure that long documents are computed first. For corpora with a skewed document length distribution this is significantly faster. The variables "nchars" is also added to the original object.


library(quanteda)
library(future)
library(future.apply)




future_lingsummarize <- function(dt,
                                 threads = detectCores(),
                                 chunksize = 1){


    begin.dopar <- Sys.time()

    dt <- dt[,.(doc_id, text)]
    
    nchars <- dt[, lapply(.(text), nchar)]
    
    print(paste0("Parallel processing using ",
                 threads,
                 " threads. Begin at ",
                 begin.dopar,
                 ". Processing ",
                 dt[,.N],
                 " documents with a total length of ",
                 sum(nchars),
                 " characters."))

    
    ord <- order(-nchars)
    dt <- dt[ord]
    
    cl <- makeForkCluster(threads)
    registerDoParallel(cl)
    

    itx <- iter(dt["nchars" > 0],
                by = "row",
                chunksize = chunksize)
    
    result.list <- foreach(i = itx,
                           .errorhandling = 'pass') %dopar% {

                               corpus <- corpus(i)
                               
                               tokens <- tokens(corpus,
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
                               
                               ntokens <- unname(ntoken(tokens))
                               ntypes  <- unname(ntype(tokens))
                               nsentences <- unname(nsentence(corpus))

                               temp <- data.table(ntokens,
                                                  ntypes,
                                                  nsentences)
                               
                               return(temp)
                           }
    
    stopCluster(cl)


    end.dopar <- Sys.time()
    duration.dopar <- end.dopar - begin.dopar

    result.dt <- rbindlist(result.list)

    summary.corpus <- cbind(nchars[ord],
                            result.dt)

    setnames(summary.corpus,
             "V1",
             "nchars")


    if(dt["nchars" == 0, .N] > 0){
        
        dt.charnull <- dt["nchars" == 0]
        dt.charnull$text <- NULL
        dt.charnull$ntokens <- rep(0, dt.charnull[,.N])
        dt.charnull$ntypes <- rep(0, dt.charnull[,.N])
        dt.charnull$nsentences <- rep(0, dt.charnull[,.N])

        summary.corpus <- rbind(summary.corpus,
                                dt.charnull)
    }

    
    summary.corpus <- summary.corpus[order(ord)]

    
    print(paste0("Runtime was ",
                 round(duration.dopar,
                       digits = 2),
                 " ",
                 attributes(duration.dopar)$units,
                 ". Ended at ",
                 end.dopar, "."))
    
    return(summary.corpus)

}

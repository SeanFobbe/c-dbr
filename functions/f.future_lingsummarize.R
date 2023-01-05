#'# future_lingsummarize
#' Iterated parallel computation of characters, tokens, types and sentences for each document of a given data table. Documents must contain text in a "text" variable and document names in a "doc_id" variable. The functionality is similar to textstats_summary() from the quanteda.textstats package, but this function is optimized for parallel processing of very large corpora.
#'
#' During computation documents are ordered by number of characters (descending) to ensure that long documents are computed first. For corpora with a skewed document length distribution this is significantly faster. The variables "nchars" is also added to the original object.


# library(quanteda)
# library(future)
# library(future.apply)




f.future_lingsummarize <- function(dt,
                                 chunksperworker = 1,
                                 chunksize = NULL){

    begin.dopar <- Sys.time()

    dt <- dt[,.(doc_id, text)]
    
    nchars <- dt[, lapply(.(text), nchar)]$V1
    
    print(paste0("Processing ",
                 dt[,.N],
                 " documents with a total length of ",
                 sum(nchars),
                 " characters."))

    
    ord <- order(-nchars)
    dt <- dt[ord]

    raw.list <- split(dt, seq(nrow(dt)))
    
    result.list <- future_lapply(raw.list,
                                 f.lingsummarize,
                                 future.seed = TRUE,
                                 future.scheduling = chunksperworker,
                                 future.chunk.size = chunksize)
    
    result.dt <- rbindlist(result.list)

    

    end.dopar <- Sys.time()
    duration.dopar <- end.dopar - begin.dopar


    summary.corpus <- cbind(nchars[ord],
                            result.dt)

    setnames(summary.corpus,
             "V1",
             "nchars")

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









f.lingsummarize <- function(dt){

    corpus <- corpus(dt)
    
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
    nsentences <- suppressWarnings(unname(nsentence(corpus)))

    out <- data.table(ntokens,
                      ntypes,
                      nsentences)
    
    return(out)

    
}



#' #' Summarize linguistic variables in a given data set.

#' @param x Data.table. Containing texts in a "text" variable and the output of the special f.lingstats() function for targets pipelines.
#' @param germanvars Logical. Whether to return variable names in German. Defaults to FALSE.


#' @param return Data.table. A table with summary statistics for each linguistic statistic.






f.lingstats_summary <- function(x,
                                germanvars = FALSE){

    if(germanvars == TRUE){

        vars <- c("zeichen",
                  "tokens",
                  "typen",
                  "saetze")


    }else{
        
        vars <- c("nchars",
                  "ntokens",
                  "ntypes",
                  "nsentences") 
    }


    


    dt.summary.ling <- x[, lapply(.SD,
                                  function(x)unclass(summary(x))),
                         .SDcols = vars]


    dt.sums.ling <- x[,
                      lapply(.SD, sum),
                      .SDcols = vars]



    tokens.temp <- tokens(corpus(x),
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


    if(germanvars == TRUE){

        dt.sums.ling$typen <- nfeat(dfm(tokens.temp))
        

    }else{
        
        dt.sums.ling$ntypes <- nfeat(dfm(tokens.temp))
        
    }

    




    dt.stats.ling <- rbind(dt.sums.ling,
                           dt.summary.ling)

    dt.stats.ling <- transpose(dt.stats.ling,
                               keep.names = "names")


    if(germanvars == TRUE){

        setnames(dt.stats.ling, c("Variable",
                                  "Summe",
                                  "Min",
                                  "Quart1",
                                  "Median",
                                  "Mittel",
                                  "Quart3",
                                  "Max"))
        

    }else{
        
        setnames(dt.stats.ling, c("Variable",
                                  "Sum",
                                  "Min",
                                  "Quart1",
                                  "Median",
                                  "Mean",
                                  "Quart3",
                                  "Max"))
        
    }
    


    return(dt.stats.ling)


    
    
}

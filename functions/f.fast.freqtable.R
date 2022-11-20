

#'# f.fast.freqtable: Fast Frequency Tables
#' This function create frequency tables for an arbitrary number of variables. It can return them as a list, write them to an arbitrary folder on disk as CSV files (with an optional prefix and return kable tables that are designed to work well with render() and LaTeX. It is based on data.table and is therefore capable of processing massive data ssets. To show the kable output in render() you must add the Chunk Option "results = 'asis'" when calling the function.
#'



#+
#'## Required Arguments


#' @param x A data.table.


#+
#'## Optional arguments


#' @param varlist Character. An optional character vector of variable names to construct tables for. Defaults to all variables.
#' @param sumrow Logical. Whether to add a summary row.
#' @param output.list Logical. Whether to output the frequency tables as a list. Defaults to TRUE. Returns NULL otherwise.
#' @param output.kable Logical. Whether to return kable tables. Defaults to FALSE.
#' @param output.csv Logical. Whether to write CSV files to disk. Defaults to FALSE.
#' @param outputdir Character. The target directory for writing CSV files. Defaults to the current R working directory.
#' @param prefix A string to be added to each CSV file. Default is not to add a string and just to output the variable name as the name of the CSV file.
#' @param align Alignment of table columns. Passed to kable. Default is "r". Modifications must take into account five columns.



#'## Required Packages

# library(data.table)
# library(knitr)
# library(kableExtra)


#'## Function

f.fast.freqtable <- function(x,
                             varlist = names(x),
                             sumrow = TRUE,
                             output.list = TRUE,
                             output.kable = FALSE,
                             output.csv = FALSE,
                             outputdir = "./",
                             prefix = "",
                             align = "r"){
    
    ## Begin List
    freqtable.list <- vector("list", length(varlist))

    ## Calculate Frequency Table
    for (i in seq_along(varlist)){
        
        varname <- varlist[i]
        
        freqtable <- x[, .N, keyby=c(paste0(varname))]
        
        freqtable[, c("roundedpercent",
                      "cumulpercent") := {
                          exactpercent  <-  N/sum(N)*100
                          roundedpercent <- round(exactpercent, 2)
                          cumulpercent <- round(cumsum(exactpercent), 2)
                          list(roundedpercent,
                               cumulpercent)}]

        ## Calculate Summary Row
        if (sumrow == TRUE){
            colsums <-  cbind("Total",
                              freqtable[, lapply(.SD, function(x){round(sum(x))}),
                                        .SDcols = c("N",
                                                    "roundedpercent")
                                        ], round(max(freqtable$cumulpercent)))
            
            colnames(colsums)[c(1,4)] <- c(varname, "cumulpercent")
            freqtable <- rbind(freqtable, colsums)
        }
        
        ## Add Frequency Table to List
        freqtable.list[[i]] <- freqtable

        ## Write CSV
        if (output.csv == TRUE){
            
            fwrite(freqtable,
                   file.path(outputdir,
                             paste0(prefix,
                                    varname,
                                    ".csv")),
                   na = "NA")

        }

        ## Output Kable
        if (output.kable == TRUE){

            cat("\n------------------------------------------------\n")
            cat(paste0("Frequency Table for Variable:   ", varname, "\n"))
            cat("------------------------------------------------\n")
            cat(paste0("\n ",
                       x[, .N, keyby=c(paste0(varname))][,.N],
                       " unique value(s) detected.\n\n"))

            
            print(kable(freqtable,
                        format = "latex",
                        align = align,
                        booktabs = TRUE,
                        longtable = TRUE) %>% kable_styling(latex_options = "repeat_header"))
        }
    }



    ## Return List of Frequency Tables
    if (output.list == TRUE){

        ## Add names to list
        names(freqtable.list) <- varlist
        
        return(freqtable.list)
    }
}

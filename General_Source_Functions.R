
#'# Introduction


#+
#'## Overview
#' This proto-package combines a number of functions that should be useful during the creation of new data sets, particularly text corpora. All of the functions in this package are reasonably well-tested in real-world scenarios.
#'
#' The collection of functions is still in early and very active development. Function names, functionality and requirements may change drastically for some time yet.


#+
#'## Usage
#' Simply download the R script into the directory of your choice and call it from within R like so:

### source("General_Source_Functions.R")





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

#library(data.table)
#library(knitr)
#library(kableExtra)


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
        
        freqtable[, c("exactpercent",
                      "roundedpercent",
                      "cumulpercent") := {
                          exactpercent  <-  N/sum(N)*100
                          roundedpercent <- round(exactpercent, 2)
                          cumulpercent <- round(cumsum(exactpercent), 2)
                          list(exactpercent,
                               roundedpercent,
                               cumulpercent)}]

        ## Calculate Summary Row
        if (sumrow == TRUE){
            colsums <-  cbind("Total",
                              freqtable[, lapply(.SD, function(x){round(sum(x))}),
                                        .SDcols = c("N",
                                                    "exactpercent",
                                                    "roundedpercent")
                                        ], round(max(freqtable$cumulpercent)))
            
            colnames(colsums)[c(1,5)] <- c(varname, "cumulpercent")
            freqtable <- rbind(freqtable, colsums)
        }
        
        ## Add Frequency Table to List
        freqtable.list[[i]] <- freqtable

        ## Write CSV
        if (output.csv == TRUE){
            
            fwrite(freqtable,
                   paste0(outputdir,
                          prefix,
                          varname,
                          ".csv"),
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
        return(freqtable.list)
    }
}




#'# f.show.values: Show example values of data.table as kable
#' This function functions much like the standard data.table print behaviour, only that the result is a kable table. This is is useful when Listings throws an error for unknown symbols, as kable tables are processed with regular LaTeX, not listings.


#'@param x A data.table for which example values are to be shown.

f.show.values <- function(x){
    length <- length(x)
    rows.final <- seq((x[,.N] - 4), x[,.N], 1)

    for (index.begin in seq(1, length, 4)){
        index.end <- index.begin + 3

        if(index.end > length){
            index.end <- length
        }

        print(kable(x[c(1:5,
                        rows.final),
                      index.begin:index.end],
              format = "latex",
              align = c("p{4cm}"),
              booktabs = TRUE,
              longtable = TRUE))
    }
}






#'# f.dopar.pagenums: Parallelized Computation of the length (in pages) of PDF files
#' This function computes the maximum number of pages for each PDF file. Ideally used with sum() to get the total number of pages of all PDF files in a folder. 


#+
#'## Required Arguments


#' @param x A vector of PDF filenames. Should be located in the working directory.



#'## Required Packages

#library(doParallel)
#library(pdftools)

#'## Function
    

f.dopar.pagenums <- function(x,
                             sum = FALSE,
                             threads = detectCores()){
    
    print(paste("Parallel processing using", threads, "threads."))

    cl <- makeForkCluster(threads)
    registerDoParallel(cl)

    pagenums <- foreach(filename = x,
                        .combine = 'c',
                        .errorhandling = 'remove',
                        .inorder = TRUE) %dopar% {
                            pdf_length(filename)
                        }
    stopCluster(cl)

    if (sum == TRUE){
        sum.out <- sum(pagenums)
        print(paste("Total number of pages:", sum.out))
        return(sum.out)
    }else{
        return(pagenums)
    }
    
}








#'# f.dopar.pdfextract: Parallelized Extraction of text from PDF files
#' This function parallelizes the extraction of text from each PDF file and saves the results as TXT files. Only the file extension is modified.


#+
#'## Required Arguments


#' @param x A vector of PDF filenames. Should be located in the working directory.




#'## Required Packages

#library(doParallel)
#library(pdftools)

#'## Function

f.dopar.pdfextract <- function(x,
                               threads = detectCores()){

    begin.extract <- Sys.time()
    
    print(paste("Parallel processing using", threads, "threads. Begin at", begin.extract))

    
    cl <- makeForkCluster(threads)
    registerDoParallel(cl)

    newnames <- gsub("\\.pdf",
                     "\\.txt",
                     x)

    result <- foreach(i = seq_along(x),
                      .errorhandling = 'pass') %dopar% {            

                          ## Extract text layer from PDF
                          pdf.extracted <- pdf_text(x[i])

                          ## Write TXT to Disk
                          write.table(pdf.extracted,
                                      newnames[i],
                                      quote = FALSE,
                                      row.names = FALSE,
                                      col.names = FALSE)
                   }
    stopCluster(cl)
    
    end.extract <- Sys.time()
    duration.extract <- end.extract - begin.extract
    
    print(paste0("Processed ",
                  length(result),
                  " files. Runtime was ",
                  round(duration.extract,
                        digits = 2),
                  " ",
                  attributes(duration.extract)$units,
                  ". Ended at ",
                 end.extract, "."))

    return(result)

}















#'# f.dopar.pdfocr: Parallelized Extraction of text from PDF files
#' This function extracts the text from scanned PDF files to separate TXT files and further creates an enhanced PDF version with new OCR text grafted to the scan. It runs in nested parallelization, with tesseract calling up to 3 or 4 threads to process a single PDF file and the number of jobs determines how many PDF files are processed in parallel. Very, very CPU intensive. Will only work on Linux.


#+
#'## Required Arguments


#' @param x A vector of PDF filenames. Should be located in the working directory.
#' @param dpi The resolution at which PDF files should be converted. Defaults to 300.
#' @param lang The languages which should be expected during the OCR step, as string. Passed directly to tesseract. Default is "eng" for English. Multiple languages possible, e.g. "eng+fra" for English and French. Order of language matters.
#' @param output The output which should be generated, as string. Passed directly to tesseract. Default is "pdf txt" for PDF and TXT output.
#' @param jobs The number of jobs which should be run in parallel. Tesseract calls up to 4 threads by itself, so it should be somewhere around the full number of cores divided by 4. This is also the default. 



#'## Required Packages

## library(doParallel)

#'## Required System Libraries

## tesseract
## imagemagick


f.dopar.pdfocr <- function(x,
                           dpi = 300,
                           lang = "eng",
                           output = "pdf txt",
                           jobs = round(detectCores() / 4)){

    begin.ocr <- Sys.time()
    
    print(paste("Parallel processing running", jobs, "jobs. Begin at", begin.ocr))

    cl <- makeForkCluster(jobs)
    registerDoParallel(cl)
    

    result <- foreach(file = x,
                      .combine = 'c') %dopar% {
                          
                          name.tiff <- gsub("\\.pdf",
                                            "\\.tiff",
                                            file)
                          
                          name.out <- gsub("\\.pdf",
                                           "_TESSERACT",
                                           file)
                          
                          system2("convert",
                                  paste("-density",
                                        dpi,
                                        "-depth 8 -compress LZW -strip -background white -alpha off",
                                        file,
                                        name.tiff))
                          
                          system2("tesseract",
                                  paste(name.tiff,
                                        name.out,
                                        "-l",
                                        lang,
                                        output))
                          
                          unlink(name.tiff)
                      }

    stopCluster(cl)
    
    end.ocr <- Sys.time()
    duration.ocr <- end.ocr - begin.ocr
    
    print(paste0("Processed ",
                  length(result),
                  " files. Runtime was ",
                  round(duration.ocr,
                        digits = 2),
                  " ",
                  attributes(duration.ocr)$units,
                  ". Ended at ",
                 end.ocr, "."))
    
    return(result)

}




















#'# f.dopar.multihashes
#' This function parallelizes computation of both SHA2-256 and SHA3-512 hashes for an arbitrary number of files. It returns a data frame of file names, SHA2-256 hashes and SHA3-512 hashes.


#+
#'## Required Arguments


#' @param x A vector of filenames. Should be located in the working directory.


#+
#'## Required: OpenSSL System Library
#' The function requires the existence of the OpenSSL library on the system. This is because the openssl package for R does not provide SHA 3 capabilities yet.

#'# Required Packages

#library(doParallel)



f.dopar.multihashes <- function(x,
                                threads = detectCores()){
    
    print(paste("Parallel processing using", threads, "threads."))

    begin <- Sys.time()
    
    cl <- makeForkCluster(threads)
    registerDoParallel(cl)

    multihashes <- foreach(filename = x,
                           .errorhandling = 'pass',
                           .combine = 'rbind') %dopar% {
                               
                               sha2.256 <- system2("openssl",
                                                   paste("sha256",
                                                         filename),
                                                   stdout = TRUE)
                               
                               sha2.256 <- gsub("^.*\\= ",
                                                "",
                                                sha2.256)
                               
                               sha3.512 <- system2("openssl",
                                                   paste("sha3-512",
                                                         filename),
                                                   stdout = TRUE)
                               
                               sha3.512 <- gsub("^.*\\= ",
                                                "",
                                                sha3.512)
                               
                               out <- data.frame(filename,
                                                 sha2.256,
                                                 sha3.512)
                               return(out)
                           }
    stopCluster(cl)

    end <- Sys.time()
    duration <- end - begin
    
    print(paste0("Processed ",
                  length(x),
                  " files. Runtime was ",
                  round(duration,
                        digits = 2),
                  " ",
                  attributes(duration)$units,
                  "."))
    
    return(multihashes)
    
}





#'# f.summarize
#' Parallel computation of tokens, types and sentences for each document of a given Quanteda corpus object.
f.summarize <- function(df,
                        threads = detectCores()){
 
    print(paste("Parallel processing using", threads, "threads."))

    
    corpus <- corpus(df)

    cl <- makeForkCluster(threads)
    registerDoParallel(cl)
    
    result <- foreach(i = seq_len(ndoc(corpus)),
                      .errorhandling = 'pass') %dopar% {
                          temp <- summary(corpus[i])
                          return(temp)
                      }
    stopCluster(cl)
    
    summary.corpus <- rbindlist(result)
    return(summary.corpus)
}




#'# f.summarize.iterator
#' Iterated parallel computation of characters, tokens, types and sentences for each document of a given data table. Documents must contain text in a "text" variable and document names in a "doc_id" variable.
#'
#' During computation documents are ordered by number of characters (descending) to ensure that long documents are computed first. For corpora with a skewed document length distribution this is significantly faster. The variables "nchars" is also added to the original object.


## library(quanteda)
## library(doParallel)




f.summarize.iterator <- function(dt,
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








#'# f.dopar.spacyparse
#' Iterated parallel computation of linguistic annotations via spacy.


#' @param x A data table. Must have variables "doc_id" and "text".



f.dopar.spacyparse <- function(x,
                               threads = detectCores(),
                               chunksize = 1,
                               model = "en_core_web_sm",
                               pos = TRUE,
                               tag = FALSE,
                               lemma = FALSE,
                               entity = FALSE,
                               dependency = FALSE,
                               nounphrase = FALSE){

    begin.dopar <- Sys.time()

    spacy_initialize(model = model)

    
    print(paste0("Parallel processing using ",
                 threads,
                 " threads. Begin at ",
                 begin.dopar,
                 ". Processing ",
                 x[,.N],
                 " documents"))

    
    cl <- makeForkCluster(threads)
    registerDoParallel(cl)

    itx <- iter(x,
                by = "row",
                chunksize = chunksize)



    result <- foreach(document = itx,
                      .errorhandling = 'pass') %dopar% {
                          
                          out <- spacy_parse(document,
                                             pos = pos,
                                             tag = tag,
                                             lemma = lemma,
                                             entity = entity,
                                             dependency = dependency,
                                             nounphrase = nounphrase,
                                             multithread = FALSE)

                          return(out)}

    stopCluster(cl)
    
    txt.parsed <- rbindlist(result)
    

    end.dopar <- Sys.time()
    duration.dopar <- end.dopar - begin.dopar

    print(paste0("Runtime was ",
                 round(duration.dopar,
                       digits = 2),
                 " ",
                 attributes(duration.dopar)$units,
                 ". Ended at ",
                 end.dopar, "."))

    spacy_finalize()
    
    return(txt.parsed)


}















#'# Miscellaneous Functions



#'## f.hyphen.remove: Remove Hyphenation across Linebreaks
#' Hyphenation spanning linebreaks is a serious issue for longer texts. Hyphenated words are often not recognized as a single token by standard tokenization. The result is two mostly non-expressive and unique tokens instead of a single and expressive token. The function removes linebreaking hyphenations. It does not attempt to cover hyphenation spanning pagebreaks, as there is often confounding header/footer/footnote text in extracted text from PDFs which needs to be uniquely processed for specific corpora.
#'
#' The first REGEX matches regular hyphenation of words. The second REGEX matches compounds (e.g. SARS-CoV-2) broken across lines.


#'@param text A character vector of text.



f.hyphen.remove <- function(text){
    ## Examples: Ham-\nburg, Mei-\n   nungsäußerung
    text.out <- gsub("([a-zöäüß])-[[:blank:]]*\n[[:blank:]]*([a-zöäüß])",
                     "\\1\\2",
                     text)
    ## Examples: SARS-CoV-\n2
    text.out <- gsub("([a-zA-ZöäüÖÄÜß])-[[:blank:]]*\n[[:blank:]]*([A-Z0-9ÖÄÜß])",
                     "\\1-\\2",
                     text.out)
    ## Example: hat-    2\nte, Unsterb-    6\nliche
    text.out <- gsub("([a-zöäüß])-[[:blank:]]*[0-9]+[[:blank:]]*\n[[:blank:]]*([a-zöäüß])",
                     "\\1\\2",
                     text.out)
    
    ## Example: hat-  \n  2 te, Unsterb-  \n  6 liche
    text.out <- gsub("([a-zöäüß])-[[:space:]]*[0-9]+[[:blank:]]*([a-zöäüß])",
                     "\\1\\2",
                     text.out)
    
    return(text.out)
}



#  test <- "Ham-\nburg Mei-\n   nungsäußerung SARS-CoV-\n2  hat-    2\nte  Unsterb-    6\nliche  hat-  \n  2 te, Unsterb-  \n  6 liche"





#+
#'## f.randomID: Add random ID to Data Tables
#' Adds a randomID for each row to a Data Table object via in-place modification.


#' @param x A data.table.

f.randomID <- function(x){

    x[, randomID := {
        randomID <- sample(.N, .N)
        list(randomID)
        }]
    }





#+
#'## f.linkextract: Extract Links from HTML
#' This function extracts all links (i.e. href attributes of <a> tags) from an arbitrary HTML document. Returns "NA" if there is an error.
#'

#' @param URL A valid URL.

#library(rvest)

f.linkextract <- function(URL){
    tryCatch({
        read_html(URL) %>%
            html_nodes("a")%>%
            html_attr('href')},
        error=function(cond) {
            return(NA)}
        )
}






#'## f.year.iso: Tranform Double-Digit Years to ISO Year Format
#' This function transforms double-digit years (YY) to four-digit years as per the ISO standard (YYYY). It is based on the assumption that years above a certain boundary belong to the 20th century and years at or below that boundary belong to the 21st century.
#'
#'
#'
#' @param inputyear A vector of two-digit years.
#' @param boundary The boundary year. Default is 50 (=1950). 


f.year.iso <- function(inputyear, boundary=50){
    ifelse(inputyear > boundary,
           1900+inputyear,
           2000+inputyear)
}


#'## f.age: Calculate human age
#' Calculates age from date of birth to target date. Vectorized.

#' @param birthdate Date of birth
#' @param target Target date

f.age <- function(birthdate, target){
    if (is.na(birthdate) | is.na(target)){
        return(NA)
    }else{
        age <- year(target) - year(birthdate) - 1
        if (month(target) > month(birthdate)){
            age <- age + 1
        }
        if (month(target) == month(birthdate) && mday(target) >= mday(birthdate)){
            age <- age + 1
        }
        return(age)
    }
}

f.age <- Vectorize(f.age)




#'## f.boxplot.body: Calculate boxplot body for use with logarithmic axes in ggplot2
#' When plotting a boxplot on a logarithmic scale ggplot2 incorrectly performs the statistical transformation first before calculating the boxplot statistics. While median and quartiles are based on ordinal position the inter-quartile range differs depending on when statistical transformation is performed.
#'
#' This function calculates the boxplot body for use with ggplot2's stat_summary. Solution is based on this SO question: https://stackoverflow.com/questions/38753628/ggplot-boxplot-length-of-whiskers-with-logarithmic-axis

f.boxplot.body = function(x) {
    
    body = log10(boxplot.stats(10^x)[["stats"]])
    
    names(body) = c("ymin",
                   "lower",
                   "middle",
                   "upper",
                   "ymax")
    
    return(body)
    
}  

#'## f.boxplot.outliers: Calculate boxplot outliers for use with logarithmic axes in ggplot2
#' When plotting a boxplot on a logarithmic scale ggplot2 incorrectly performs the statistical transformation first before calculating the boxplot statistics. While median and quartiles are based on ordinal position the inter-quartile range differs depending on when statistical transformation is performed.
#'
#' This function calculates outliers for use with ggplot2's stat_summary. Solution is based on this SO question: https://stackoverflow.com/questions/38753628/ggplot-boxplot-length-of-whiskers-with-logarithmic-axis

f.boxplot.outliers = function(x) {
    
    data.frame(y = log10(boxplot.stats(10^x)[["out"]]))
    
}



#'## f.empty.list.NA: Replaces empty elements in list with "NA"
f.list.empty.NA <- function(x) if (length(x) == 0) NA_character_ else paste(x, collapse = " ")





#'## f.empty.vector.NA: Replaces empty elements in vector with "NA"
f.vec.empty.NA <- function(x) gsub("^$", "NA", x)


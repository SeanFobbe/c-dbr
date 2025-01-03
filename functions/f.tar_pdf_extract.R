#' Parallel conversion of PDF files to TXT
#'
#' Extracts PDF files and converts to TXT files. Parallelized. Compatible with the targets framework. 

#' @param x Character. A vector of PDF filenames.
#' @param outputdir Character. The directory to store the extracted TXT files in.

f.tar_pdf_extract <- function(x,
                              outputdir = "txt",
                              ignore.error = TRUE,
                              multicore = TRUE,
                              cores = parallel::detectCores()){

    ## Remove and recreate target directory
    unlink(outputdir, recursive = TRUE)
    dir.create(outputdir)

    ## Parallel Computing Settings
    if(multicore == TRUE){

        plan("multicore",
             workers = cores)
        
    }else{

        plan("sequential")

    }

    ## Extract Files
    pdf_extract(x,
                outputdir = outputdir,
                ignore.error = ignore.error)

    ## Return Value
    files.txt <- list.files(outputdir, pattern = "\\.txt", full.names = TRUE)

    return(files.txt)
    
}




#'## Parallelized Conversion of PDF to TXT

#' Extracts text from PDF files and writes the result to disk as TXT files. Parallel implementation with the future package. Resulting TXT files have the same filename as the original document (only the extension is modified).
#'
#' Please note that you must declare your own future evaluation strategy prior to using the function to enable parallelization. By default the function will be evaluated sequentially. On Windows, use future::plan(multisession, workers = n), on Linux/Mac, use future::plan(multicore, workers = n), where n stands for the number of CPU cores you wish to use. Due to the need to read from the disk the function may not work properly on high-performance clusters.


#' @param x A vector of PDF filenames.
#' @param quiet Supress messages.
#'
#' 
#' @return A set of TXT files on disk with the same basename as the original PDF files. Invisible return in R session.



#' @export



pdf_extract <- function(x,
                        outputdir = NULL,
                        ignore.error = TRUE,
                        quiet = TRUE){

    ## Timestamp: Begin
    begin.extract <- Sys.time()

    ## Intro messages
    if(quiet == FALSE){
        message(paste("Begin at:", begin.extract))
        message(paste("Processing", length(x), "PDF files."))
    }

    ## Perform conversion from PDF to TXT

    if(ignore.error == TRUE){

        invisible(future.apply::future_lapply(x,
                                              pdf_extract_single_robust,
                                              outputdir = outputdir,
                                              future.seed = TRUE))

    }else{

        invisible(future.apply::future_lapply(x,
                                              pdf_extract_single,
                                              outputdir = outputdir,
                                              future.seed = TRUE))
        
    }


    ## Construct full list of TXT names
    txt.names <- gsub("\\.pdf$",
                      "\\.txt",
                      x,
                      ignore.case = TRUE)

    ## Check list of TXT files in folder
    txt.results <- file.exists(txt.names)
    
    ## Timestamp: End
    end.extract <- Sys.time()

    ## Duration
    duration.extract <- end.extract - begin.extract

    
    ## Outro messages
    if(quiet == FALSE){
        message(paste0("Successfully processed ",
                       sum(txt.results),
                       " PDF files. ",
                       sum(!txt.results),
                       " PDF files failed."))
        
        message(paste0("Runtime was ",
                       round(duration.extract,
                             digits = 2),
                       " ",
                       attributes(duration.extract)$units,
                       "."))
        
        message(paste0("Ended at: ",
                       end.extract))
    }

}





pdf_extract_single_robust <- function(x,
                                      outputdir = NULL){
    tryCatch({pdf_extract_single(x = x,
                                 outputdir = outputdir)
    },
    error = function(cond) {
        return(NA)}
    )
}






pdf_extract_single <- function(x,
                               outputdir = NULL){

    tryCatch({
        
        ## Extract text layer from PDF
        pdf.extracted <- pdftools::pdf_text(x)

        ## TXT filename
        txtname <- gsub("\\.pdf$",
                        "\\.txt",
                        x,
                        ignore.case = TRUE)

        ## Alternate Folder Option
        if (!is.null(outputdir)){
            
            txtname <- file.path(outputdir, basename(txtname))
            
        }
        
        ## Write TXT to Disk
        utils::write.table(pdf.extracted,
                           txtname,
                           quote = FALSE,
                           row.names = FALSE,
                           col.names = FALSE)


    },
    error = function(cond) {
        return(NA)}
    )

    
}

#' Extract filenames from GII HTMl Landing Pages
#'
#' @param url.xml Character. Vector of URLs to zipped XML archives on www.gesetze-im-internet.de
#' @param multicore Logical. Whether to use multiple cores.
#' @param cores Integer. Number of cores to use.
#'
#'
#' @return Data.table. A table of all PDF and EPUB filenames.




f.html_landing_pages <- function(url.xml,
                                 multicore = TRUE,
                                 cores = parallel::detectCores()){

    if(multicore == TRUE){

        future::plan("multicore",
                     workers = cores)
        
    }else{

        future::plan("sequential")

    }

    
    ## HTML URLs erstellen
    url.html <- gsub("/xml.zip",
                     "/index.html",
                     url.xml)


    ## Landing Pages auswerten
    names.list <- future.apply::future_lapply(url.html,
                                              f.linkextract_regex,
                                              regex = "(.pdf$)|(.epub$)")



    ## Dateinamen von PDF und EPUB-Dateien in separate Vektoren sortieren

    names.pdf <- lapply(names.list, grep, pattern = "pdf", value = TRUE)
    names.pdf <- lapply(names.pdf, f.zero.NA)
    filenames.pdf <- unlist(names.pdf)


    names.epub <- lapply(names.list, grep, pattern = "epub", value = TRUE)
    names.epub <- lapply(names.epub, f.zero.NA)
    filenames.epub <- unlist(names.epub)



    ## Test: Gleiche Länge der Dateinamen-Vektoren


    if (!length(url.html) == length(filenames.pdf)){

        stop("PDF-Dateinamen sind fehlerhaft.")
        
    }


    if (!length(url.html) == length(filenames.epub)){

        stop("EPUB-Dateinamen sind fehlerhaft.")
        
    }


    dt <- data.table(filenames.pdf,
                     filenames.epub)
    
    
    return(dt)
    

}


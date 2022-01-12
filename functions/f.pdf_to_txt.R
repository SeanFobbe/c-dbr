#'## Conversion of PDF to TXT

#' Extracts text from PDF files and writes the result to disk as TXT files. Resulting TXT files have the same filename as the original document (only the extension is modified).
#'


#' @param x Path to a PDF file.
#'
#' 
#' @return A TXT file on disk with the same basename as the original PDF file.


pdf_to_txt <- function(x){
    
    ## Extract text layer from PDF
    pdf.extracted <- pdftools::pdf_text(x)

    ## TXT filename
    txtname <- gsub("\\.pdf",
                    "\\.txt",
                    x,
                    ignore.case = TRUE)
    
    ## Write TXT to Disk
    utils::write.table(pdf.extracted,
                       txtname,
                       quote = FALSE,
                       row.names = FALSE,
                       col.names = FALSE)
    
}

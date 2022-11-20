#' Konkordanztabelle für Titel erstellen
#'
#' @param dt.download Data.table. Die Download-Tabelle für GII.
#'
#' @return Data.table. Eine Tabelle mit ID, Kurzitel und Langtitel



f.conctable <- function(dt.download){

    
    ID <- gsub("\\.epub",
               "",
               basename(dt.download$url.epub))

    conctable <- data.table(ID = ID,
                            kurztitel = dt.download$shorttitle,
                            langtitel = dt.download$longtitle.raw)

    return(conctable)
    

}

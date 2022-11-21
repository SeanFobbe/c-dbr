#' Datensatz erstellen: XML-Metadaten
#' Mit der Funktion werden Metadaten für alle Rechtsakte von "Gesetze im Internet" erhoben, unabhängig davon ob die Rechtsakte Text enthalten oder nur mit Überschrift nachgewiesen sind.
#'
#' @param file.xml Character. Vektor mit Pfaden zu XML-Dateien von www.gesetze-im-internet.de
#'
#' @return Data.table. Eine Tabelle mit den Metadaten jedes Rechtsaktes aus den XML-Dateien.



f.dt.meta <- function(file.xml,
                      multicore = FALSE,
                      cores = parallel::detectCores()){

    ## Parallelisierung

    if(multicore == TRUE){

        plan("multicore",
             workers = cores)
        
    }else{

        plan("sequential")

    }




    ## XML Parse
    out.meta <- future_lapply(file.xml,
                              xmlparse.meta.robust)



    ## Liste in Data Table umwandeln
    dt.meta <- rbindlist(out.meta,
                         use.names = TRUE,
                         fill = TRUE)




    ## Variablen-Name für Ausfertigungsdatum anpassen

    setnames(dt.meta,
             "ausfertigung-datum",
             "ausfertigung_datum")



    ## Variable "fundstellentyp" anpassen
    dt.meta[grep("amtlich",
                 dt.meta$fundstellentyp,
                 invert = TRUE)]$fundstellentyp <- "nichtamtlich"


    ## Variable "builddate_iso" erstellen

    dt.meta$builddate_iso <- as.POSIXct(dt.meta$builddate_original,
                                        format = "%Y%m%d%H%M%S")



    ## Variable "aenderung_datum" erstellen

    dt.meta$aenderung_datum <- as.Date(gsub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                            "\\1",
                                            dt.meta$stand),
                                       format = "%d.%m.%Y")


    
    ## Variable "aufhebung_verkuendung_datum" erstellen
    ## Das Textfeld mit Informationen zur Aufhebung enthält zwei Daten. Das erste ist das der Verkündung des aufhebenden Rechtsaktes, das zweite das der Wirkung des aufhebenden Rechtsaktes. Für diese Variable wird das erste Datum verwendet.

    dt.meta$aufhebung_verkuendung_datum <- as.Date(sub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                                       "\\1",
                                                       dt.meta$aufh),
                                                   format = "%d.%m.%Y")


    
    ## Variable "aufhebung_wirkung_datum" erstellen
    ## Das Textfeld mit Informationen zur Aufhebung enthält zwei Daten. Das erste ist das der Verkündung des aufhebenden Rechtsaktes, das zweite das der Wirkung des aufhebenden Rechtsaktes. Für diese Variable wird das zweite Datum verwendet.

    dt.meta$aufhebung_wirkung_datum <- as.Date(sub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                                   "\\2",
                                                   dt.meta$aufh),
                                               format = "%d.%m.%Y")



    ## Variable "neufassung_datum" erstellen

    dt.meta$neufassung_datum <- as.Date(gsub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                             "\\1",
                                             dt.meta$neuf),
                                        format = "%d.%m.%Y")




    ## Variable "ausfertigung_jahr" hinzufügen
    dt.meta$ausfertigung_jahr <- year(as.IDate(dt.meta$ausfertigung_datum))


    ## Variable "doi_concept" hinzufügen
    dt.meta$doi_concept <- rep(config$doi$data$concept, dt.meta[,.N])


    ## Variable "doi_version" hinzufügen
    dt.meta$doi_version <- rep(config$doi$data$version, dt.meta[,.N])


    ## Variable "version" hinzufügen
    dt.meta$version <- as.character(rep(datestamp, dt.meta[,.N]))

    ## Variable "lizenz" hinzufügen
    dt.meta$lizenz <- as.character(rep(config$license$data,
                                       dt.meta[,.N]))



    return(dt.meta)

    
    
}







xmlparse.meta.robust <- function(file.xml){
    tryCatch({xmlparse.meta(file.xml)},
             error = function(cond) {
                 return(NA)}
             )
}






xmlparse.meta <- function(file.xml){

    ## XML-Struktur lesen
    XML <- read_xml(file.xml)

    ## Schleife vorbereiten
    nodes <- html_elements(XML, xpath = "//norm//metadaten")
    scope <- 1:length(nodes)


    ## Metadaten extrahieren

    varlist <- c("jurabk",
                 "amtabk",
                 "ausfertigung-datum",
                 "periodikum",
                 "zitstelle",
                 "langue",
                 "kurzue")
    
    meta <- vector("list", length(varlist))
    
    for (i in 1:length(varlist)){
        meta[[i]] <- html_element(XML, varlist[i]) %>% xml_text()

    }

    setDT(meta)
    setnames(meta, new = varlist)
    
    meta$fundstellentyp <- html_element(XML, "fundstelle") %>% xml_attr(attr = "typ")
    
    meta$doc_id <- basename(file.xml)
    
    meta$builddate_original <- xml_attr(XML, attr = "builddate")

    ## Standangaben extrahieren
    standtyp <- html_elements(XML, "standtyp") %>% xml_text(trim = TRUE)
    standkommentar <- html_elements(XML, "standkommentar") %>% xml_text(trim = TRUE)
    standcheck <- html_elements(XML, "standangabe") %>% xml_attr(attr = "checked")

    dt.stand <- data.table(standtyp,
                           standkommentar,
                           standcheck)

    if (dt.stand[,.N] > 0){
        
        ## Standkommentar
        dt.typ <- dt.stand[,
                           lapply(list(standkommentar),
                                  function(x)paste(x, collapse = "   ")),
                           keyby = c("standtyp")]

        setnames(dt.typ,
                 "V1",
                 "standkommentar")

        dt.typ <- transpose(dt.typ,
                            make.names = "standtyp")

        setnames(dt.typ,
                 names(dt.typ),
                 tolower(names(dt.typ)))

        ## Standcheck
        dt.check <- dt.stand[,lapply(.SD, as.factor)][, .(standtyp, standcheck)]
        dt.check <- dt.check[, lapply(list(standtyp), unique), keyby = "standcheck"]
        setnames(dt.check,
                 "V1",
                 "standtyp")

        dt.check <- transpose(dt.check,
                              make.names = "standtyp")

        setnames(dt.check,
                 names(dt.check),
                 paste0("check_",
                        tolower(names(dt.check))))
        
        dt.stand.all <- cbind(dt.typ, dt.check)


        meta <- cbind(meta,
                      dt.stand.all)
    }
    
    return(meta)
    
}








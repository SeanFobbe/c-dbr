#' Korpus erstellen: Einzelnormen
#' 
#' **Wichtiger Hinweis:** Es werden für diese Variante nur Rechtsakte ausgewertet, bei denen mindestens eine Einzelnorm mit Text-Inhalt vorhanden ist!
#'
#' Die XML-Daten enthalten keine Leerzeichen zwischen den XML-Tags, sowie zwischen den XML-Tags und ihrem Inhalt. Damit beim Entfernen der XML-Tags keine Inhalte zusammengefügt werden, wird die XML-Datei zunächst als Character-Vektor eingelesen, Leerzeichen hinzugefügt und im Anschluss erst die XML-Struktur eingelesen. Zwischen dem Anfang des Dokuments und dem ersten XML-Tag darf kein Leerzeichen sein, dieses wird einzeln nachkorrigiert. Zusätzlicher whitespace ist bei späterer Text-Verarbeitung unschädlich und wird im Rahmen der Tokenisierung praktisch immer entfernt.
#'
#' Ohne diesen Schritt können Ergebnisse so aussehen: "Zollkodex,d)alle Verfahren"
#'
#'
#' @param file.xml Character. Vektor mit Pfaden zu XML-Dateien von www.gesetze-im-internet.de
#'
#' @return Data.table. Eine Tabelle mit den Texten und Metadaten jeder Einzelorm aus den XML-Dateien.




f.dt.einzelnormen <- function(file.xml,
                              multicore = FALSE,
                              cores = parallel::detectCores()){





    ## Parallelisierung

    if(multicore == TRUE){

        plan("multicore",
             workers = cores)
        
    }else{

        plan("sequential")

    }


    ## Einzelnormen-Parse
    out.einzelnormen <- future_lapply(file.xml,
                                      xmlparse.einzelnormen.robust)


    ## Liste in Data Table umwandeln
    dt.normen <- rbindlist(out.einzelnormen,
                           use.names = TRUE,
                           fill = TRUE)
    


    ## Variable "doc_id" erstellen
    ## Eine einzigartige doc_id wird benötigt um z.B. einen Quanteda-Korpus erstellen zu können. Diese wird aus dem Dateinamen zusammen mit einer Kollisionsnummer gebildet.

    dt.normen$doc_id <- make.unique(dt.normen$dateiname)


    ## Variablen-Name für Ausfertigungsdatum anpassen

    setnames(dt.normen,
             "ausfertigung-datum",
             "ausfertigung_datum")
    

    ## Variable "fundstellentyp" anpassen
    dt.normen[grep("amtlich",
                   dt.normen$fundstellentyp,
                   invert = TRUE)]$fundstellentyp <- "nichtamtlich"



    ## Variable "builddate_iso" erstellen

    dt.normen$builddate_iso <- as.POSIXct(dt.normen$builddate_original,
                                          format = "%Y%m%d%H%M%S")



    ## Variable "aenderung_datum" erstellen

    dt.normen$aenderung_datum <- as.Date(gsub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                              "\\1",
                                              dt.normen$stand),
                                         format = "%d.%m.%Y")
    

    ## Variable "aufhebung_verkuendung_datum" erstellen
    ## Das Textfeld mit Informationen zur Aufhebung enthält zwei Daten. Das erste ist das der Verkündung des aufhebenden Rechtsaktes, das zweite das der Wirkung des aufhebenden Rechtsaktes. Für diese Variable wird das erste Datum verwendet.

    dt.normen$aufhebung_verkuendung_datum <- as.Date(sub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                                         "\\1",
                                                         dt.normen$aufh),
                                                     format = "%d.%m.%Y")

    ## Variable "aufhebung_wirkung_datum" erstellen
    #' Das Textfeld mit Informationen zur Aufhebung enthält zwei Daten. Das erste ist das der Verkündung des aufhebenden Rechtsaktes, das zweite das der Wirkung des aufhebenden Rechtsaktes. Für diese Variable wird das zweite Datum verwendet.

    dt.normen$aufhebung_wirkung_datum <- as.Date(sub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                                     "\\2",
                                                     dt.normen$aufh),
                                                 format = "%d.%m.%Y")



    ## Variable "neufassung_datum" erstellen

    dt.normen$neufassung_datum <- as.Date(gsub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                               "\\1",
                                               dt.normen$neuf),
                                          format = "%d.%m.%Y")






    ## Variable "ausfertigung_jahr" hinzufügen
    dt.normen$ausfertigung_jahr <- year(dt.normen$ausfertigung_datum)





    ## Variable "doi_concept" hinzufügen
    dt.normen$doi_concept <- rep(config$doi$data$concept,
                                 dt.normen[,.N])


    ## Variable "doi_version" hinzufügen
    dt.normen$doi_version <- rep(config$doi$data$version,
                                 dt.normen[,.N])


    ## Variable "version" hinzufügen
    dt.normen$version <- as.character(rep(datestamp,
                                          dt.normen[,.N]))

    ## Variable "lizenz" hinzufügen
    dt.normen$lizenz <- as.character(rep(config$license$data,
                                         dt.normen[,.N]))



    return(dt.normen)




}






xmlparse.einzelnormen.robust <- function(file.xml){
    tryCatch({xmlparse.einzelnormen(file.xml)},
             error = function(cond) {
                 return(NA)}
             )
}







xmlparse.einzelnormen <- function(file.xml){
    
    ## XML als Character-Vektor einlesen
    xml.char <- readChar(file.xml,
                         file.info(file.xml)$size)

    ## Leerzeichen einfügen
    xml.char <- gsub(">", "> ", xml.char)
    xml.char <- gsub("<", " <", xml.char)
    xml.char <- sub(" <", "<", xml.char)

    ## XML-Struktur lesen
    XML <- read_xml(xml.char)

    ## Schleife vorbereiten
    nodes <- html_elements(XML, xpath = "//norm")
    scope <- seq_along(nodes)
    
    ## Inhaltsdaten extrahieren
    text.temp <- vector("list", max(scope))
    enbez.temp <- vector("list", max(scope))
    g.kennzahl.temp <- vector("list", max(scope))
    g.bez.temp <- vector("list", max(scope))
    g.titel.temp <- vector("list", max(scope))
    
    for (i in scope){
        
        text.temp[[i]] <- html_elements(nodes[i],
                                        xpath = "textdaten//text//Content")  %>% xml_text(trim = TRUE)
        
        enbez.temp[[i]] <- html_elements(nodes[i],
                                         xpath = "metadaten//enbez")  %>% xml_text(trim = TRUE)
        
        g.kennzahl.temp[[i]] <- html_elements(nodes[i],
                                              xpath = "metadaten//gliederungseinheit//gliederungskennzahl") %>% xml_text(trim = TRUE)
        
        g.bez.temp[[i]] <- html_elements(nodes[i],
                                         xpath = "metadaten//gliederungseinheit//gliederungsbez")  %>% xml_text(trim = TRUE)
        
        g.titel.temp[[i]] <- html_elements(nodes[i],
                                           xpath = "metadaten//gliederungseinheit//gliederungstitel")  %>% xml_text(trim = TRUE)
        
    }

    ## Leere Elemente mit NA kennzeichnen
    enbez <- sapply(enbez.temp, f.zero.NA)
    text <- sapply(text.temp, f.zero.NA)
    g.kennzahl.pos <- sapply(g.kennzahl.temp, f.zero.NA)
    g.bez.pos <- sapply(g.bez.temp, f.zero.NA)
    g.titel.pos <- sapply(g.titel.temp, f.zero.NA)
    
    ## Gliederungsinformationen transformieren
    gliederungskennzahl <- f.heading.transform(g.kennzahl.pos)
    gliederungsbez <- f.heading.transform(g.bez.pos)
    gliederungstitel <- f.heading.transform(g.titel.pos)


    ## Grundlage für Ketten extrahieren
    g.kennzahl.vec <- html_elements(XML, xpath = "//norm//gliederungskennzahl") %>% xml_text(trim = TRUE)
    g.bez.vec <- html_elements(XML, xpath = "//norm//gliederungsbez") %>% xml_text(trim = TRUE)
    g.titel.vec <- html_elements(XML, xpath = "//norm//gliederungstitel") %>% xml_text(trim = TRUE)

    ## Ketten anhand von Gliederungskennzahlen erstellen
    chain.dt <- f.namechain(g.kennzahl.vec,
                            g.titel.vec,
                            g.bez.vec)

    ## Ketten einfügen
    titelkette <- chain.dt$titelchain[match(gliederungskennzahl,
                                            chain.dt$einzelzahl)]

    bezkette <- chain.dt$bezchain[match(gliederungskennzahl,
                                        chain.dt$einzelzahl)]


    ## Build Date extrahieren
    builddate_original <- xml_attr(nodes, attr = "builddate")

    ## Content Data Table erstellen
    content.out <- data.table(builddate_original,
                              gliederungskennzahl,
                              gliederungsbez,
                              bezkette,
                              gliederungstitel,
                              titelkette,
                              enbez,
                              text)

    content.out <- content.out[text != ""]                                                 
    
    
    ## Allgemeine Metadaten extrahieren

    varlist <- c("jurabk",
                 "amtabk",
                 "ausfertigung-datum",
                 "periodikum",
                 "zitstelle",
                 "langue",
                 "kurzue")

    
    meta <- vector("list", length(varlist))
    
    for (i in 1:length(varlist)){
        
        temp    <- html_element(XML, varlist[i]) %>% xml_text(trim = TRUE)
        meta[[i]]  <- rep(temp,
                          content.out[,.N])
        
    }
    
    setDT(meta)
    setnames(meta, new = varlist)
    
    meta$fundstellentyp <- rep(html_element(XML, "fundstelle") %>% xml_attr(attr = "typ"),
                               content.out[,.N])


    meta$dateiname <- rep(basename(file.xml),
                          content.out[,.N])
    

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
                                  function(x)paste(x, collapse = " | ")),
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

        dt.check <- transpose(dt.check, make.names = "standtyp")

        setnames(dt.check,
                 names(dt.check),
                 paste0("check_",
                        tolower(names(dt.check))))
        
        dt.stand.all <- cbind(dt.typ, dt.check)



        dt.stand.all.rep <- dt.stand.all[rep(dt.stand.all[, .I],
                                             content.out[,.N])]


        out.dt <- cbind(meta,
                        dt.stand.all.rep,
                        content.out)
    }else{
        out.dt <- cbind(meta,
                        content.out)
    }
    
    return(out.dt)
    
}






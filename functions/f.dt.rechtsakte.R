#' Korpus aller Rechtsakte erstellen

#' @param dt.normen Data.table. Die Tabelle aller Einzelnormen von GII, die mit der Funktion f.dt.normen erstellt wurde.
#'
#' @return Data.table. Eine Tabelle aller Rechtsakte, mit Text und Metadaten.



f.dt.rechtsakte <- function(dt.normen){

   
    ## Der vordefinierte Satz an Metadaten.

    varlist.r1 <- c("jurabk",
                    "amtabk",
                    "ausfertigung_datum",
                    "periodikum",
                    "zitstelle",
                    "langue",
                    "kurzue")
    


    ## Die Stand-Variablen haben immer ein Pendant das mit "check_" beginnt.

    standvars <- c("stand",
                   "aufh",
                   "neuf",
                   "hinweis",
                   "sonst")

    standvars <- c(standvars,
                   paste0("check_",
                          standvars))


    ## Vollständiger Satz an Variablen

    varlist.r2 <- c(varlist.r1,
                    standvars,
                    "fundstellentyp",
                    "ausfertigung_jahr",
                    "aenderung_datum",
                    "aufhebung_verkuendung_datum",
                    "aufhebung_wirkung_datum",
                    "neufassung_datum",
                    "doi_concept",
                    "doi_version",
                    "version",
                    "lizenz")



    ## Einzelnormen zu Rechtsakten vereinigen

    text.rechtsakte <- dt.normen[,
                                 lapply(list(text),
                                        function(x)paste(x, collapse = " ")),
                                 keyby = dateiname]


    setnames(text.rechtsakte,
             "V1",
             "text")


    meta.rechtsakte <- dt.normen[,
                                 lapply(.SD, unique),
                                 .SDcols = varlist.r2,
                                 keyby = dateiname]


    dt.rechtsakte <- text.rechtsakte[meta.rechtsakte,
                                     on = "dateiname"]


    ## Variable "dateiname" in "doc_id" umbenennen

    setnames(dt.rechtsakte,
             "dateiname",
             "doc_id")


    return(dt.rechtsakte)


}

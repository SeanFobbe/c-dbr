#' Datensatz mit Rechtsakten finalisieren
#'
#' @param dt.rechtsakte Data.table. Der fast-finale Datensatz mit den Rechtsakten.
#' @param lingstats Data.table. Die linguistischen Kennzahlen für die Rechtsakte.
#'
#' @return Data.table. Der finalisierte und geprüfte Datensatz.




f.finalize_rechtsakte <- function(dt.rechtsakte,
                                    lingstats){



    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {
        expect_s3_class(dt.rechtsakte, "data.table")
        expect_s3_class(lingstats, "data.table")
    })

    
    ## Lingstats einfügen
    dt.final <- cbind(dt.rechtsakte,
                      lingstats)
    

    ## Semantische Sortierung der Variablen
    
    setcolorder(dt.final,
                c("doc_id",
                  "text",
                  "jurabk",
                  "amtabk",
                  "langue",
                  "kurzue",
                  "ausfertigung_datum",
                  "ausfertigung_jahr",        
                  "aenderung_datum",
                  "aufhebung_verkuendung_datum",
                  "aufhebung_wirkung_datum",
                  "neufassung_datum",
                  "fundstellentyp",
                  "periodikum",
                  "zitstelle",
                  "stand",
                  "aufh",
                  "neuf",
                  "hinweis",
                  "sonst",
                  "check_stand",
                  "check_aufh",
                  "check_neuf",
                  "check_hinweis",
                  "check_sonst",
                  "zeichen",
                  "tokens",
                  "typen",
                  "saetze",
                  "doi_concept",
                  "doi_version",
                  "version",
                  "lizenz"))


    ## Unit Test
    test_that("Ergebnis entspricht Erwartungen.", {
        expect_s3_class(dt.final, "data.table")
        expect_equal(dt.final[,.N], dt.rechtsakte[,.N])
    })


    return(dt.final)

    
}

#' Datensatz mit Einzelnormen finalisieren
#'
#' @param dt.normen Data.table. Der fast-finale Datensatz mit den Einzelnormen.
#' @param lingstats Data.table. Die linguistischen Kennzahlen für die Einzelnormen
#'
#' @return Der finalisierte und geprüfte Datensatz.




f.finalize_einzelnormen <- function(dt.normen,
                                    lingstats){



    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {
        expect_s3_class(dt.normen, "data.table")
        expect_s3_class(dt.lingstats, "data.table")
    })

    
    ## Lingstats einfügen
    dt.final <- cbind(dt.normen,
                      lingstats)
    

    ## Semantische Sortierung der Variablen
    
    setcolorder(dt.final,
                c("doc_id",
                  "dateiname",
                  "text",
                  "jurabk",
                  "amtabk",
                  "langue",
                  "kurzue",
                  "gliederungskennzahl",
                  "gliederungsbez",
                  "gliederungstitel",
                  "enbez",
                  "bezkette",
                  "titelkette",
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
                  "builddate_original",
                  "builddate_iso",
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
        expect_equal(dt.final[,.N], dt.normen[,.N])
    })


    return(dt.final)

    
}

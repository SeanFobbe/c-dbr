#'# Erstellen von Titel- und Bezeichnungshierarchien
#' Diese Funktion nimmt die für jedes Gesetz bereitgestellten Gliederungskennzahlen, bricht diese in ihre Bestandteile herunter und definiert für jede Gliederungskennzahl die volle Hierarchie an Titeln bzw. Gliederungsbezeichnungen.
#'
#' Beispiel Titelhierarchie: Recht der Schuldverhältnisse | Einzelne Schuldverhältnisse | Mietvertrag, Pachtvertrag | Mietverhältnisse über Wohnraum | Beendigung des Mietverhältnisses | Werkwohnungen
#'
#' Beispiel Bezeichnungshierarchie: Buch 2 | Abschnitt 8 | Titel 5 | Untertitel 2 | Kapitel 5 | Unterkapitel 4


f.namechain <- function(kennzahl,
                        titel,
                        bez){

    out.list <- vector("list", length(kennzahl))
    
    for (i in seq_along(kennzahl)){
        
        einzelzahl <- kennzahl[i]
        
        breaks <- seq_len(nchar(einzelzahl) / 3 ) * 3

        chain <- unname(mapply(substr, einzelzahl, 1, breaks))

        titelchain <- paste(titel[match(chain, kennzahl)], collapse = " | ")

        bezchain <- paste(bez[match(chain, kennzahl)], collapse = " | ")

        out.list[[i]] <- data.table(einzelzahl,
                                    titelchain,
                                    bezchain)
    }
    
    out.vec <- rbindlist(out.list)
    
    return(out.vec)
    
}


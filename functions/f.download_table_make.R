#' Download Table erstellen
#'
#'
#' @param dt.filenames Data.table. Tabelle mit PDF- und EPUB-Dateinamen von www.gesetze-im-internet.de
#' @param url.xml Character. Vektor mit URLs zu als ZIP verpackten XML-Dateien von GII.
#' @param xml.toc Character. XML-Inhaltsverzeichnis von GII.
#'
#' @return Data.table. Eine fertige Download-Tabelle mit Namen und URLs für alle Formate.





f.download_table_make <- function(dt.filenames,
                                  url.xml,
                                  xml.toc = "https://www.gesetze-im-internet.de/gii-toc.xml"){


    ## Split Filename Table
    filenames.pdf <- dt.filenames$filenames.pdf
    filenames.epub <- dt.filenames$filenames.epub
    

    ## XML TOC einlesen
    xml <- xml2::read_xml(xml.toc)
    

    ## === Vektor der Langtitel erstellen ===
    ## **Hinweis:** Es gibt einige Rechtsakte mit gleichem Namen aber unterschiedlichem Inhalt. Die Rechtsakte werden daher um ihr jeweiliges Ausfertigungsjahr ergänzt, um die Dateinamen einzigartig zu machen.

    longtitle.elements <- rvest::html_elements(xml, "title")
    longtitle.raw  <- xml2::xml_text(longtitle.elements)



    ## Namen bereinigen und kürzen

    longtitle <- gsub("[[:punct:]]", "", longtitle.raw)
    longtitle <- gsub(" ", "-", longtitle)



    ## Indizes der AEG bestimmen
    AEG.index <- grep("Allgemeines-Eisenbahngesetz", longtitle)


    ## AEGs umbenennen
    longtitle[AEG.index] <- c("Allgemeines-Eisenbahngesetz-1993",
                              "Allgemeines-Eisenbahngesetz-1951")


    ## Vektor der Kurztitel erstellen

    shorttitle <- filenames.pdf

    shorttitle <- gsub(".pdf",
                       "",
                       shorttitle)

    shorttitle <- gsub("_",
                       "",
                       shorttitle)



    ## === Vektoren der Titel vereinigen ===
    
    ## Die Kurz- und Langtitel werden zu einem Vektor zusammengefügt. Dieser wird dann auf maximal 200 Zeichen gekürzt, damit keine Probleme für Windows-User entstehen. 

    title <- paste(shorttitle,
                   longtitle,
                   sep = "_")

    title <- strtrim(title,
                     200)





    ## Bereinigung von Namens-Kollisionen
    #' Eine manuelle Bereinigung von Kollisionen ist bevorzugt. Falls keine manuelle Bereinigung stattgefunden hat wird in diesem Schritt eine automatische Bereinigung durchgeführt.

    title <- make.unique(title,
                         sep = "-")



    ## Dateierweiterungen hinzufügen

    title.xml <- paste0(title, ".zip")
    title.epub <- paste0(title, ".epub")
    title.pdf <- paste0(title, ".pdf")



    ## Links zu EPUB-Dateien erstellen

    pre.url.epub <- gsub("xml.zip",
                         "",
                         url.xml)

    url.epub <- paste0(pre.url.epub,
                       filenames.epub)


    #'## Links zu  PDF-Dateien erstellen

    pre.url.pdf <- gsub("xml.zip",
                        "",
                        url.xml)

    url.pdf <- paste0(pre.url.pdf,
                      filenames.pdf)



    #'## Data Table für Download vorbereiten

    dt.final <- data.table(title,
                           longtitle,
                           longtitle.raw,
                           shorttitle,
                           title.xml,
                           url.xml,
                           title.epub,
                           url.epub,
                           title.pdf,
                           url.pdf)


    return(dt.final)

    
    
}

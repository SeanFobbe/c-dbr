#'---
#'title: "Compilation Report | Corpus des Deutschen Bundesrechts"
#'author: Seán Fobbe
#'geometry: margin=3cm
#'papersize: a4
#'fontsize: 11pt
#'output:
#'  pdf_document:
#'    toc: true
#'    toc_depth: 3
#'    number_sections: true
#'    pandoc_args: --listings
#'    includes:
#'      in_header: tex/Preamble_DE.tex
#'      before_body: [temp/C-DBR_Definitions.tex, tex/C-DBR_CompilationTitle.tex]
#'bibliography: temp/packages.bib
#'nocite: '@*'
#'---

#+ echo = FALSE 
knitr::opts_chunk$set(echo = TRUE,
                      warning = TRUE,
                      message = TRUE)


#'# Einleitung

#+
#'## Überblick
#' Dieses Skript wertet das amtliche Internetangebot \enquote{Gesetze im Internet} (\url{https://www.gesetze-im-internet.de}) der Bundesrepublik Deutschland vollständig aus und kompiliert es in einen reichhaltigen menschen- und maschinenlesbaren Korpus. Es ist die Grundlage des **\datatitle\ (\datashort)**.
#'
#' Alle mit diesem Skript erstellten Datensätze werden dauerhaft kostenlos und urheberrechtsfrei auf Zenodo, dem wissenschaftlichen Archiv des CERN, veröffentlicht. Alle Versionen sind mit einem persistenten Digital Object Identifier (DOI) versehen. Die neueste Version des Datensatzes ist immer über den Link der Concept DOI erreichbar: \url{https://doi.org/10.5281/zenodo.3832111}


#+
#'## Endprodukte

#' Primäre Endprodukte des Skripts sind folgende ZIP-Archive:
#'
#' \begin{enumerate}
#' \item Der volle Datensatz im CSV-Format, unterteilt in Einzelnormen; nur Rechtsakte mit veröffentlichtem Normtext sind erfasst
#' \item Die Metadaten aller Einzelnormen im CSV-Format (wie 1, nur ohne Normtexte)
#' \item Der volle Datensatz im CSV-Format, unterteilt in Rechtsakte; nur Rechtsakte mit veröffentlichtem Normtext sind erfasst
#' \item Die Metadaten aller Rechtsakte im CSV-Format (wie 3, nur ohne Normtexte)
#' \item Die Metadaten aller auf \enquote{Gesetze im Internet} als XML veröffentlichten Rechtsakte, im CSV-Format, unabhängig davon ob sie Normtext enthalten oder nicht
#' \item Der volle Datensatz im XML-Format, unterteilt in Rechtsakte; Grundlage für die CSV-Varianten
#' \item Alle Anlagen zu den XML-Dateien im jeweiligen Original-Format
#' \item Alle Rechtstexte im TXT-Format, unterteilt in Rechtsakte (deutlich reduzierter Umfang an Metadaten)
#' \item Alle Rechtstexte im PDF-Format, unterteilt in Rechtsakte (deutlich reduzierter Umfang an Metadaten)
#' \item Alle Rechtstexte im EPUB-Format, unterteilt in Rechtsakte (deutlich reduzierter Umfang an Metadaten)
#' \item Alle Analyse-Ergebnisse (Tabellen als CSV, Grafiken als PDF und PNG)
#' \item Netzwerk-Strukturen (Adjazenzmatrizen, Edgelists, GraphML, und Netzwerk-Diagramme) für alle Rechtsakte (experimentell!)
#' \end{enumerate}
#'
#' Zusätzlich werden für alle ZIP-Archive kryptographische Signaturen (SHA2-256 und SHA3-512) berechnet und in einer CSV-Datei hinterlegt. Die Analyse-Ergebnisse werden zum Ende hin nicht gelöscht, damit sie für die Codebook-Erstellung verwendet werden können. Weiterhin kann optional ein PDF-Bericht erstellt werden (siehe unter "Kompilierung").


#'\newpage
#+
#'## Kompilierung
#' Mit der Funktion **render()** von **rmarkdown** können der **vollständige Datensatz** und das **Codebook** kompiliert und die Skripte mitsamt ihrer Rechenergebnisse in ein gut lesbares PDF-Format überführt werden.
#'
#' Alle Kommentare sind im roxygen2-Stil gehalten. Die beiden Skripte können daher auch **ohne render()** regulär als R-Skripte ausgeführt werden. Es wird in diesem Fall kein PDF-Bericht erstellt und Diagramme werden nicht abgespeichert.

#+
#'### Datensatz 
#' 
#' Um den **vollständigen Datensatz** zu kompilieren und einen PDF-Bericht zu erstellen, kopieren Sie bitte alle im Source-Archiv bereitgestellten Dateien in einen leeren Ordner und führen mit R diesen Befehl aus:

#+ eval = FALSE

source("00_C-DBR_FullCompile.R")



#'\newpage
#+
#'## Systemanforderungen
#' Das Skript in seiner veröffentlichten Form kann nur unter Linux ausgeführt werden, da es Linux-spezifische Optimierungen (z.B. Fork Cluster) und Shell-Kommandos (z.B. OpenSSL) nutzt. Das Skript wurde unter Fedora Linux entwickelt und getestet. Die zur Kompilierung benutzte Version entnehmen Sie bitte dem **sessionInfo()**-Ausdruck am Ende dieses Berichts.
#'
#' In der Standard-Einstellung wird das Skript vollautomatisch die maximale Anzahl an Rechenkernen/Threads auf dem System zu nutzen. Wenn die Anzahl Threads (Variable "fullCores") auf 1 gesetzt wird, ist die Parallelisierung deaktiviert.
#'
#' Auf der Festplatte sollten 8 GB Speicherplatz vorhanden sein.
#' 
#' Um die PDF-Berichte kompilieren zu können benötigen Sie das R package **rmarkdown**, eine vollständige Installation von \LaTeX\ und alle in der Präambel-TEX-Datei angegebenen \LaTeX\ Packages.






#'\newpage



#+
#'# Vorbereitung


#+ Datumsstempel
#'## Datumsstempel
#' Dieser Datumsstempel wird in alle Dateinamen eingefügt. Er wird am Anfang des Skripts gesetzt, für den den Fall, dass die Laufzeit die Datumsbarriere durchbricht.

datestamp <- Sys.Date()
print(datestamp)



#'## Datum und Uhrzeit (Beginn)
begin.script <- Sys.time()
print(begin.script)






#+ Packages
#'## Packages Laden
#' Das package *groundhog* nimmt eine strenge Versionskontrolle von R packages vor, indem es nur solche Versionen lädt, die an einem bestimmten Stichtag auf CRAN verfügbar waren. Diese werden in einer separaten library gesichert. Falls entsprechende Versionen nicht vorhanden sind, nimmt es eine automatische Installation derselben vor.

library(groundhog)    # Strenge Versionskontrolle von R packages

packages <- c("zip",          # ZIP Files
              "rvest",        # HTML/XML-Extraktion
              "xml2",         # Verarbeitung von XML-Format
              "RcppTOML",     # Verarbeitung von TOML-Format
              "knitr",        # Professionelles Reporting
              "kableExtra",   # Verbesserte Kable Tabellen
              "magick",       # Verarbeitung von Bild-Dateien
              "pdftools",     # Extrahieren von PDF-Dateien
#              "parallel",     # Parallelisierung
#              "doParallel",   # Parallelisierung
              "ggplot2",      # Fortgeschrittene Datenvisualisierung
              "data.table",   # Fortgeschrittene Datenverarbeitung
              "quanteda",     # Fortgeschrittene Computerlinguistik
              "scales",       # Skalierung von Diagrammen
              "openssl",      # Kryptographische Signaturen
              "igraph",       # Analyse von Graphen
              "ggraph",       # Analyse von Graphen
              "qgraph",
              "future",
              "future.apply")       # Analyse von Graphen


groundhog.library(pkg = packages,
                  date = "2021-02-20")



#'## Zusätzliche Funktionen einlesen
#' **Hinweis:** Die hieraus verwendeten Funktionen werden jeweils vor der ersten Benutzung in vollem Umfang angezeigt um den Lesefluss zu verbessern.

source("R-fobbe-proto-package/f.linkextract.R")
source("R-fobbe-proto-package/f.fast.freqtable.R")
source("R-fobbe-proto-package/f.lingsummarize.iterator.R")
source("R-fobbe-proto-package/f.dopar.pagenums.R")
source("R-fobbe-proto-package/f.dopar.pdfextract.R")
source("R-fobbe-proto-package/f.dopar.multihashes.R")

source("functions/f.heading.transform.R")
source("functions/f.namechain.R")
source("functions/f.zero.NA.R")



#'## Verzeichnis für Analyse-Ergebnisse und Diagramme definieren
#' Muss mit einem Schrägstrich enden!

dir.analysis <- paste0(getwd(),
                    "/analyse/") 


#'## Weitere Verzeichnisse definieren

dirs <- c("output",
          "temp",
          "netzwerke",
          "XML",
          "PDF",
          "TXT",
          "EPUB")



#'## Dateien aus vorherigen Runs bereinigen


unlink(dir.analysis, recursive = TRUE)

unlink(dirs, recursive = TRUE)


#'## Verzeichnisse anlegen

dir.create(dir.analysis)

lapply(dirs, dir.create)


dir.create("netzwerke/Edgelists")
dir.create("netzwerke/Adjazenzmatrizen")
dir.create("netzwerke/Netzwerkdiagramme")
dir.create("netzwerke/GraphML")



#'## Vollzitate statistischer Software schreiben
knitr::write_bib(c(.packages()),
                 "temp/packages.bib")




#'## Allgemeine Konfiguration

#+
#'### Konfiguration einlesen
config <- parseTOML("C-DBR_Config.toml")

#'### Konfiguration anzeigen
print(config)



#+
#'### Knitr Optionen setzen
knitr::opts_chunk$set(fig.path = dir.analysis,
                      dev = config$fig$format,
                      dpi = config$fig$dpi,
                      fig.align = config$fig$align)


#'### Download Timeout setzen
options(timeout = config$download$timeout)



#'### Quellenangabe für Diagramme definieren

caption <- paste("Fobbe | DOI:",
                 config$doi$data$version)
print(caption)


#'### Präfix für Dateien definieren

prefix.files <- paste0(config$project$shortname,
                 "_",
                 datestamp)
print(prefix.files)


#'### Präfix für Diagrammed definieren

prefix.figuretitle <- paste(config$project$shortname,
                            "| Version",
                            datestamp)

#'### Quanteda-Optionen setzen
quanteda_options(tokens_locale = config$quanteda$tokens_locale)




#'## LaTeX Konfiguration

#+
#'### LaTeX Parameter definieren

latexdefs <- c("%===========================\n% Definitionen\n%===========================",
               "\n% NOTE: Diese Datei wurde während des Kompilierungs-Prozesses automatisch erstellt.\n",
               "\n%-----Autor-----",
               paste0("\\newcommand{\\projectauthor}{",
                      config$project$author,
                      "}"),
               "\n%-----Version-----",
               paste0("\\newcommand{\\version}{",
                      datestamp,
                      "}"),
               "\n%-----Titles-----",
               paste0("\\newcommand{\\datatitle}{",
                      config$project$fullname,
                      "}"),
               paste0("\\newcommand{\\datashort}{",
                      config$project$shortname,
                      "}"),
               paste0("\\newcommand{\\softwaretitle}{Source Code des \\enquote{",
                      config$project$fullname,
                      "}}"),
               paste0("\\newcommand{\\softwareshort}{",
                      config$project$shortname,
                      "-Source}"),
               "\n%-----Data DOIs-----",
               paste0("\\newcommand{\\dataconceptdoi}{",
                      config$doi$data$concept,
                      "}"),
               paste0("\\newcommand{\\dataversiondoi}{",
                      config$doi$data$version,
                      "}"),
               paste0("\\newcommand{\\dataconcepturldoi}{https://doi.org/",
                      config$doi$data$concept,
                      "}"),
               paste0("\\newcommand{\\dataversionurldoi}{https://doi.org/",
                      config$doi$data$version,
                      "}"),
               "\n%-----Software DOIs-----",
               paste0("\\newcommand{\\softwareconceptdoi}{",
                      config$doi$software$concept,
                      "}"),
               paste0("\\newcommand{\\softwareversiondoi}{",
                      config$doi$software$version,
                      "}"),

               paste0("\\newcommand{\\softwareconcepturldoi}{https://doi.org/",
                      config$doi$software$concept,
                      "}"),
               paste0("\\newcommand{\\softwareversionurldoi}{https://doi.org/",
                      config$doi$software$version,
                      "}"))



#'\newpage
#'### LaTeX Parameter schreiben

writeLines(latexdefs,
           paste0("temp/",
                  config$project$shortname,
                  "_Definitions.tex"))






#'## Parallelisierung aktivieren
#' Parallelisierung wird zur Beschleunigung des XML-Parsings, der Konvertierung von PDF zu TXT und der Datenanalyse mittels **quanteda** und **data.table** verwendet. Die Anzahl threads wird automatisch auf das verfügbare Maximum des Systems gesetzt, kann aber auch nach Belieben auf das eigene System angepasst werden. Die Parallelisierung kann deaktiviert werden, indem die Variable **fullCores** auf 1 gesetzt wird.
#'
#' Die hier verwendete Funktion **makeForkCluster()** ist viel schneller, funktioniert aber nur auf Unix-basierten Systemen (Linux, MacOS). Bei einer Ausführung unter Windows sollten Sie **makecluster()** verwenden.


#+
#'### Anzahl logischer Kerne festlegen

if (config$cores$max == TRUE){
    fullCores <- detectCores()
}


if (config$cores$max == FALSE){
    fullCores <- as.integer(config$cores$number)
}



print(fullCores)

#'### Quanteda
quanteda_options(threads = fullCores) 

#'### Data.table
setDTthreads(threads = fullCores)  






#'# Download vorbereiten

#+
#'## XML-Inhaltsverzeichnis einlesen

URL <- "https://www.gesetze-im-internet.de/gii-toc.xml"

XML <- read_xml(URL)


#'## Links zu XML-Dateien aus XML-Inhaltsverzeichnis extrahieren

links <- xml_nodes(XML,
                   "link")

links.xml <- xml_text(links)


#'## Links zu HTML Landing Pages generieren

links.html <- gsub("/xml.zip",
                   "/index.html",
                   links.xml)


#'## Funktion anzeigen: f.linkextract
print(f.linkextract)


#'## Links aus HTML Landing Pages extrahieren

plan("multicore",
     workers = 4)

links.list <- future_lapply(links.html,
                            f.linkextract)




links.raw <- unlist(links.list)


#'## Dateinamen von PDF und EPUB-Dateien in separate Vektoren sortieren

filenames.pdf <- grep (".pdf$",
                       links.raw,
                       ignore.case = TRUE,
                       value = TRUE)

filenames.epub <- grep (".epub$",
                        links.raw,
                        ignore.case = TRUE,
                        value = TRUE)



#'## Vektor der Langtitel erstellen
#' 
#' **Hinweis:** Es gibt zwei Rechtsakte mit dem Namen "Allgemeine Eisenbahngesetz", obwohl es sich um zwei unterschiedliche Rechtsakte handelt. Die beiden Rechtsakte werden daher um ihr jeweiliges Ausfertigungsjahr ergänzt um die Dateinamen einzigartig zu machen.

longtitle.raw <- xml_nodes(XML, "title") %>% xml_text()


#'### Namen bereinigen und kürzen

longtitle <- gsub(" ", "", longtitle.raw)
longtitle <- gsub("[[:punct:]]", "", longtitle)


#'### Indizes der AEG bestimmen
AEGindex <- grep("AllgemeinesEisenbahngesetz", longtitle)


#'### AEGs umbenennen
longtitle[AEGindex] <- c("AllgemeinesEisenbahngesetz1993",
                         "AllgemeinesEisenbahngesetz1951")


#'## Vektor der Kurztitel erstellen

shorttitle <- filenames.pdf

shorttitle <- gsub(".pdf",
                   "",
                   shorttitle)

shorttitle <- gsub("_",
                   "",
                   shorttitle)



#'## Vektoren der Titel vereinigen
#'
#' Die Kurz- und Langtitel werden zu einem Vektor zusammengefügt. Dieser wird dann auf maximal 200 Zeichen gekürzt, damit keine Probleme für Windows-User entstehen. 

title <- paste(shorttitle,
               longtitle,
               sep="_")

title <- strtrim(title,
                 200)



#'## Prüfung auf Namens-Kollisionen

#' Kollidierende Namen anzeigen. Wenn Namens-Kollisionen bestehen (wie oben beim AEG) müssen diese unbedingt bereinigt werden, weil ansonsten beim Herunterladen eine Datei alle anderen mit dem gleichen Namen überschreibt.
#' 
title[duplicated(title)]


#'## Bereinigung von Namens-Kollisionen
#' Eine manuelle Bereinigung von Kollisionen ist bevorzugt. Falls keine manuelle Bereinigung stattgefunden hat wird in diesem Schritt eine automatische Bereinigung durchgeführt.

title <- make.unique(title,
                     sep = "-")



#'## Dateierweiterungen hinzufügen

title.xml <- paste0(title, ".zip")
title.epub <- paste0(title, ".epub")
title.pdf <- paste0(title, ".pdf")



#'## Links zu EPUB-Dateien erstellen

prelinks.epub <- gsub("xml.zip",
                      "",
                      links.xml)

links.epub <- paste0(prelinks.epub,
                     filenames.epub)


#'## Links zu  PDF-Dateien erstellen

prelinks.pdf <- gsub("xml.zip",
                     "",
                     links.xml)

links.pdf <- paste0(prelinks.pdf,
                    filenames.pdf)



#'## Data Table für Download vorbereiten

download <- data.table(title.xml,
                       links.xml,
                       title.epub,
                       links.epub,
                       title.pdf,
                       links.pdf)


#'## Abkürzungsverzeichnis erstellen

ID <- gsub("\\.epub",
           "",
           filenames.epub)

conctable <- data.table(ID,
                        shorttitle,
                        longtitle.raw)

colnames(conctable) <- c("ID",
                         "Kurztitel",
                         "Langtitel")



#'## Download Table als CSV speichern

fwrite(download,
       paste0(dir.analysis,
              config$project$shortname,
              "_02_Links.csv"),
       na = "NA")




#'## Verzeichnis aller Rechtsakte als CSV speichern

fwrite(conctable,
       paste0("output/",
              prefix.files,
              "_DE_AlleRechtsakteVerzeichnis.csv"),
       na = "NA")




#'## Debugging-Modus: Anzahl der heruntergeladenen Dateien reduzieren

if (config$debug$toggle == TRUE){

    download <- download[sample(download[, .N], config$debug$sample)]

}



#'## Anzahl herunterzuladender Dateien

#+
#'### Pro Format
download[, .N]

#'### Insgesamt
download[, .N] * 3




#'# Verarbeitung der DTD und XML-Dateien mit Anlagen


#+
#'## Document Type Definition herunterladen
#' Die Document Type Definition (DTD) "definiert den Aufbau des XML-Formats zur Veroeffentlichung der aktuellen Bundesgesetze und Rechtsverordnungen ueber www.gesetze-im-internet.de" (Zitat aus dem Inhalt der Datei).

download.file("https://www.gesetze-im-internet.de/dtd/1.01/gii-norm.dtd",
              paste0("output/",
                     prefix.files,
                     "_DE_XML_DocumentTypeDefinition_v1-01.dtd"))





#'## Download der XML-Dateien

plan("multicore",
     workers = fullCores)

#+ results = 'hide'
future_mapply(download.file,
              download$links.xml,
              paste0("XML/",
                     download$title.xml))



#'## Download-Ergebnis

#+
#'### Anzahl herunterzuladender Dateien
download[,.N]

#'### Anzahl heruntergeladener Dateien
files.zip <- list.files("XML",
                        pattern = "\\.zip")
length(files.zip)

#'### Fehlbetrag
N.missing <- download[,.N] - length(files.zip)
print(N.missing)

#'### Fehlende Dateien
missing <- setdiff(download$title.xml,
                   files.zip)
print(missing)



#'## Extrahieren der XML-Dateien und ihrer Anlagen
#' XML-Dateien und ihre Anlagen sind einzeln nach Rechtsakten in ZIP-Archiven verpackt. Diese werden nun extrahiert und die ZIP-Archive im Anschluss gelöscht.

#+ results = 'hide'
files.zip <- list.files("XML",
                        pattern = "\\.zip",
                        ignore.case = TRUE,
                        full.names = TRUE)


for (file in files.zip){
    unzip(zipfile = file,
          exdir = "XML")
    }


unlink(files.zip)



#'## XML Dateien auflisten und Dateigrößen speichern

files.xml <- list.files("XML",
                        pattern = "\\.xml",
                        ignore.case = TRUE,
                        full.names = TRUE)

xml.MB <- file.size(files.xml) / 10^6





#'## Korpus erstellen: Einzelnormen
#' **Wichtiger Hinweis:** Es werden für diese Variante nur Rechtsakte ausgewertet, bei denen mindestens eine Einzelnorm mit Text-Inhalt vorhanden ist!
#'
#' Die XML-Daten enthalten keine Leerzeichen zwischen den XML-Tags, sowie zwischen den XML-Tags und ihrem Inhalt. Damit beim Entfernen der XML-Tags keine Inhalte zusammengefügt werden, wird die XML-Datei zunächst als Character-Vektor eingelesen, Leerzeichen hinzugefügt und im Anschluss erst die XML-Struktur eingelesen. Zwischen dem Anfang des Dokuments und dem ersten XML-Tag darf kein Leerzeichen sein, dieses wird einzeln nachkorrigiert. Zusätzlicher whitespace ist bei späterer Text-Verarbeitung unschädlich und wird im Rahmen der Tokenisierung praktisch immer entfernt.
#'
#' Ohne diesen Schritt können Ergebnisse so aussehen: "Zollkodex,d)alle Verfahren"


#'### Funktion für XML-Parsing definieren


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
    nodes <- xml_nodes(XML, xpath = "//norm")
    scope <- seq_along(nodes)
    
    ## Inhaltsdaten extrahieren
    text.temp <- vector("list", max(scope))
    enbez.temp <- vector("list", max(scope))
    g.kennzahl.temp <- vector("list", max(scope))
    g.bez.temp <- vector("list", max(scope))
    g.titel.temp <- vector("list", max(scope))
    
    for (i in scope){
        
        text.temp[[i]] <- xml_nodes(nodes[i],
                                    xpath = "textdaten//text//Content")  %>% xml_text(trim = TRUE)
        
        enbez.temp[[i]] <- xml_nodes(nodes[i],
                                     xpath = "metadaten//enbez")  %>% xml_text(trim = TRUE)
        
        g.kennzahl.temp[[i]] <- xml_nodes(nodes[i],
                                          xpath = "metadaten//gliederungseinheit//gliederungskennzahl") %>% xml_text(trim = TRUE)
        
        g.bez.temp[[i]] <- xml_nodes(nodes[i],
                                     xpath = "metadaten//gliederungseinheit//gliederungsbez")  %>% xml_text(trim = TRUE)
        
        g.titel.temp[[i]] <- xml_nodes(nodes[i],
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
    g.kennzahl.vec <- xml_nodes(XML, xpath = "//norm//gliederungskennzahl") %>% xml_text(trim = TRUE)
    g.bez.vec <- xml_nodes(XML, xpath = "//norm//gliederungsbez") %>% xml_text(trim = TRUE)
    g.titel.vec <- xml_nodes(XML, xpath = "//norm//gliederungstitel") %>% xml_text(trim = TRUE)

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
        
        temp    <- xml_node(XML, varlist[i]) %>% xml_text(trim = TRUE)
        meta[[i]]  <- rep(temp,
                          content.out[,.N])
        
    }
    
    setDT(meta)
    setnames(meta, new = varlist)
    
    meta$fundstellentyp <- rep(xml_node(XML, "fundstelle") %>% xml_attr(attr = "typ"),
                               content.out[,.N])


    meta$dateiname <- rep(basename(file.xml),
                          content.out[,.N])
    

    ## Standangaben extrahieren
    standtyp <- xml_nodes(XML, "standtyp") %>% xml_text(trim = TRUE)
    standkommentar <- xml_nodes(XML, "standkommentar") %>% xml_text(trim = TRUE)
    standcheck <- xml_nodes(XML, "standangabe") %>% xml_attr(attr = "checked")

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



#+ Einzelnormen-Parse




#+
#'### Beginn XML Parsing
begin.parse <- Sys.time()


#'### Parallelisierung definieren

plan("multicore",
     workers = fullCores)



#'### XML Parsen

out.einzelnormen <- future_lapply(files.xml,
                                  xmlparse.einzelnormen)


#'### Liste in Data Table umwandeln
dt.normen <- rbindlist(out.einzelnormen,
                       use.names = TRUE,
                       fill = TRUE)


#'### Ende XML Parsing
end.parse <- Sys.time()

#'### Dauer XML Parsing
end.parse - begin.parse




#'### Variable "doc_id" erstellen
#' Eine einzigartige doc_id wird benötigt um z.B. einen Quanteda-Korpus erstellen zu können. Diese wird aus dem Dateinamen zusammen mit einer Kollisionsnummer gebildet.

dt.normen$doc_id <- make.unique(dt.normen$dateiname)


#'### Variablen-Name für Ausfertigungsdatum anpassen

setnames(dt.normen,
         "ausfertigung-datum",
         "ausfertigung_datum")


#'### Variable "fundstellentyp" anpassen
dt.normen[grep("amtlich",
               dt.normen$fundstellentyp,
               invert = TRUE)]$fundstellentyp <- "nichtamtlich"



#'### Variable "builddate_iso" erstellen

dt.normen$builddate_iso <- as.POSIXct(dt.normen$builddate_original,
                                      format = "%Y%m%d%H%M%S")



#'### Variable "aenderung_datum" erstellen

dt.normen$aenderung_datum <- as.Date(gsub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                          "\\1",
                                          dt.normen$stand),
                                     format = "%d.%m.%Y")


#'### Variable "aufhebung_verkuendung_datum" erstellen
#' Das Textfeld mit Informationen zur Aufhebung enthält zwei Daten. Das erste ist das der Verkündung des aufhebenden Rechtsaktes, das zweite das der Wirkung des aufhebenden Rechtsaktes. Für diese Variable wird das erste Datum verwendet.

dt.normen$aufhebung_verkuendung_datum <- as.Date(sub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                                     "\\1",
                                                     dt.normen$aufh),
                                                 format = "%d.%m.%Y")

#'### Variable "aufhebung_wirkung_datum" erstellen
#' Das Textfeld mit Informationen zur Aufhebung enthält zwei Daten. Das erste ist das der Verkündung des aufhebenden Rechtsaktes, das zweite das der Wirkung des aufhebenden Rechtsaktes. Für diese Variable wird das zweite Datum verwendet.

dt.normen$aufhebung_wirkung_datum <- as.Date(sub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                                     "\\2",
                                                     dt.normen$aufh),
                                                 format = "%d.%m.%Y")



#'### Variable "neufassung_datum" erstellen

dt.normen$neufassung_datum <- as.Date(gsub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                           "\\1",
                                           dt.normen$neuf),
                                      format = "%d.%m.%Y")






#'### Variable "ausfertigung_jahr" hinzufügen
dt.normen$ausfertigung_jahr <- year(dt.normen$ausfertigung_datum)





#'### Variable "doi_concept" hinzufügen
dt.normen$doi_concept <- rep(config$doi$data$concept,
                             dt.normen[,.N])


#'### Variable "doi_version" hinzufügen
dt.normen$doi_version <- rep(config$doi$data$version,
                             dt.normen[,.N])


#'### Variable "version" hinzufügen
dt.normen$version <- as.character(rep(datestamp,
                                      dt.normen[,.N]))

#'### Variable "lizenz" hinzufügen
dt.normen$lizenz <- as.character(rep(config$license$data,
                                     dt.normen[,.N]))






#'## Stichprobe für Qualitätsprüfung ziehen

print(config$qa$sample)

idx <- sample(dt.normen[,.N],
              config$qa$sample)

check <- dt.normen[idx]

fwrite(check,
       paste0(dir.analysis,
              prefix.files,
              "_Stichprobe_Normen.csv"),
       na = "NA")




#'\newpage
#'## Korpus erstellen: Rechtsakte

#+
#'### Variablen definieren
#' Zunächt der vordefinierte Satz an Metadaten.

varlist.r1 <- gsub("ausfertigung-datum",
                   "ausfertigung_datum",
                   varlist)

#' Die Stand-Variablen haben immer auch ein Pendant das mit "check_" beginnt.

standvars <- c("stand",
               "aufh",
               "neuf",
               "hinweis",
               "sonst")

standvars <- c(standvars,
               paste0("check_",
                      standvars))


#'### Vollständiger Satz an Variablen

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



#'### Einzelnormen zu Rechtsakten vereinigen

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


#'### Variable "dateiname" in "doc_id" umbenennen

setnames(dt.rechtsakte,
         "dateiname",
         "doc_id")









#'\newpage
#'## Datensatz erstellen: XML-Metadaten
#' An dieser Stelle werden Metadaten für alle Rechtsakte von "Gesetze im Internet" erhoben, unabhängig davon ob die Rechtsakte Text enthalten oder nur mit Überschrift nachgewiesen sind.


#'### Funktion für XML-Parsing definieren


xmlparse.meta <- function(file.xml){

    ## XML-Struktur lesen
    XML <- read_xml(file.xml)

    ## Schleife vorbereiten
    nodes <- xml_nodes(XML, xpath = "//norm//metadaten")
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
        meta[[i]] <- xml_node(XML, varlist[i]) %>% xml_text()

    }

    setDT(meta)
    setnames(meta, new = varlist)
    
    meta$fundstellentyp <- xml_node(XML, "fundstelle") %>% xml_attr(attr = "typ")
    
    meta$doc_id <- file.xml
    
    meta$builddate_original <- xml_attr(XML, attr = "builddate")

    ## Standangaben extrahieren
    standtyp <- xml_nodes(XML, "standtyp") %>% xml_text(trim = TRUE)
    standkommentar <- xml_nodes(XML, "standkommentar") %>% xml_text(trim = TRUE)
    standcheck <- xml_nodes(XML, "standangabe") %>% xml_attr(attr = "checked")

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





#+
#'### Beginn XML Parsing
begin.parse <- Sys.time()


#'### Parallelisierung definieren

plan("multicore",
     workers = fullCores)



#'### XML Parsen

out.meta <- future_lapply(files.xml,
                     xmlparse.meta)



#'### Liste in Data Table umwandeln
dt.meta <- rbindlist(out.meta,
                     use.names = TRUE,
                     fill = TRUE)


#'### Ende XML Parsing
end.parse <- Sys.time()

#'### Dauer XML Parsing
end.parse - begin.parse




#'### Variablen-Name für Ausfertigungsdatum anpassen

setnames(dt.meta,
         "ausfertigung-datum",
         "ausfertigung_datum")



#'### Variable "fundstellentyp" anpassen
dt.meta[grep("amtlich", dt.meta$fundstellentyp, invert = TRUE)]$fundstellentyp <- "nichtamtlich"


#'### Variable "builddate_iso" erstellen

dt.meta$builddate_iso <- as.POSIXct(dt.meta$builddate_original,
                                      format = "%Y%m%d%H%M%S")



#'### Variable "aenderung_datum" erstellen

dt.meta$aenderung_datum <- as.Date(gsub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                          "\\1",
                                          dt.meta$stand),
                                     format = "%d.%m.%Y")


#'### Variable "aufhebung_verkuendung_datum" erstellen
#' Das Textfeld mit Informationen zur Aufhebung enthält zwei Daten. Das erste ist das der Verkündung des aufhebenden Rechtsaktes, das zweite das der Wirkung des aufhebenden Rechtsaktes. Für diese Variable wird das erste Datum verwendet.

dt.meta$aufhebung_verkuendung_datum <- as.Date(sub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                                     "\\1",
                                                     dt.meta$aufh),
                                                 format = "%d.%m.%Y")

#'### Variable "aufhebung_wirkung_datum" erstellen
#' Das Textfeld mit Informationen zur Aufhebung enthält zwei Daten. Das erste ist das der Verkündung des aufhebenden Rechtsaktes, das zweite das der Wirkung des aufhebenden Rechtsaktes. Für diese Variable wird das zweite Datum verwendet.

dt.meta$aufhebung_wirkung_datum <- as.Date(sub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                                     "\\2",
                                                     dt.meta$aufh),
                                                 format = "%d.%m.%Y")



#'### Variable "neufassung_datum" erstellen

dt.meta$neufassung_datum <- as.Date(gsub(".*([0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}).*",
                                           "\\1",
                                           dt.meta$neuf),
                                      format = "%d.%m.%Y")




#'### Variable "ausfertigung_jahr" hinzufügen
dt.meta$ausfertigung_jahr <- year(as.IDate(dt.meta$ausfertigung_datum))


#'### Variable "doi_concept" hinzufügen
dt.meta$doi_concept <- rep(config$doi$data$concept, dt.meta[,.N])


#'### Variable "doi_version" hinzufügen
dt.meta$doi_version <- rep(config$doi$data$version, dt.meta[,.N])


#'### Variable "version" hinzufügen
dt.meta$version <- as.character(rep(datestamp, dt.meta[,.N]))

#'### Variable "lizenz" hinzufügen
dt.meta$lizenz <- as.character(rep(config$license$data,
                                     dt.meta[,.N]))







#'## Netzwerk-Analyse (experimentell)

#+
#'### Funktion definieren: f.kennzahlen.search

f.kennzahlen.search <- function(pattern, targetvec){

    pattern.N <- nchar(pattern)
    target <- substr(targetvec, 1, pattern.N)
    targetvec[grepl(pattern, target, fixed = TRUE)]
    
}


#+
#'### Funktion definieren: f.kennzahlen.collapse

f.kennzahlen.collapse <- function(lev.begin, targets.list){

    out.list <- vector("list", length(targets.list))
    
    for (i in 1:length(targets.list)){

        targets.vector <- targets.list[[i]]
        
        out.list[[i]] <- data.table(rep(lev.begin[i],
                                        length(targets.vector)),
                                    targets.vector)
        
    }

    out.vec <- rbindlist(out.list)
    return(out.vec)
    
}

#'### Funktion definieren: f.kennzahlen.edgelist

#' f.kennzahlen.edgelist: erstellt aus einem vektor an Gliederungskennzahlen und dem Gesetzesnamen ein Netzwerk-Diagramm der Inhaltsstruktur. Basiert auf f.kennzahlen.search und f.kennzahlen.collapse.

f.kennzahlen.edgelist <- function(kennzahl, name){

    level <- nchar(kennzahl) / 3

    level.unique <- sort(unique(level))

    depth.begin <- head(seq_along(level.unique), -1)
    depth.end <- depth.begin + 1

    out.list <- vector("list", length(depth.begin))

    for (i in seq_along(depth.begin)){

        lev.begin <- kennzahl[level == depth.begin[i]]
        lev.end <- kennzahl[level == depth.end[i]]

        targets.list <- lapply(lev.begin, f.kennzahlen.search, lev.end)
        out.list[[i]] <- f.kennzahlen.collapse(lev.begin, targets.list)

    }

    out.dt <- rbindlist(out.list)

    ## Add zero level

    if (length(depth.begin != 0)){
        lev1 <- kennzahl[level == depth.begin[1]]
        
        zerolinks <- data.table(rep(name, length(lev1)),
                                lev1)
        
        out.dt <- rbind(zerolinks,
                        out.dt,
                        use.names = FALSE)
    }else{
        lev1 <- kennzahl
        out.dt <- data.table(rep(name, length(lev1)),
                             lev1)
        
    }

    setnames(out.dt,
             new = c("from",
                     "to"))
    
    return(out.dt)

}


f.split.gliederungseinheit <- function(gliederungseinheit){

    kennzahl <- xml_nodes(gliederungseinheit, xpath = "gliederungskennzahl") %>% xml_text()
    
    bez <- xml_nodes(gliederungseinheit, xpath = "gliederungsbez") %>% xml_text()

    # Newlines, damit Umbrüche in Diagrammen funktionieren
    bez <- gsub(" +",
                "\n",
                bez)

    titel <- gsub(" +",
                  "\n",
                  titel)
    
    titel <- xml_nodes(gliederungseinheit, xpath = "gliederungstitel") %>% xml_text()
    
    if(length(titel) == 0){
        titel <- NA
    }

    dt <- data.table(kennzahl,
                     bez,
                     titel)
    return(dt)
    
}


xml.name <- "XML/BJNR002089971.xml" # problem
xml.name <- "XML/BJNR001950896.xml" # BGB



#'### Funktion definieren: f.network.analysis
#' f.network.analysis benötigt  f.kennzahlen.search, f.kennzahlen.collapse und f.kennzahlen.edgelist.


f.network.analysis <- function(xml.name,
                               prefix.figuretitle,
                               caption){

    message(xml.name)
    XML <- read_xml(xml.name)

    ## Gliederungseinheiten extrahieren
    gliederungseinheit <- xml_nodes(XML, xpath = "//norm//gliederungseinheit")

    ## Gliederungseinheit splitten
    gliederungseinheit.split <- lapply(gliederungseinheit,
                                       f.split.gliederungseinheit)
    gliederungseinheit.split <- rbindlist(gliederungseinheit.split)

    gliederungseinheit.split <- unique(gliederungseinheit.split, by = "kennzahl")
    

    ## Abkürzung extrahieren
    jurabk <- xml_node(XML, xpath = "//norm//jurabk") %>% xml_text()

    if (length(jurabk) == 0){
        jurabk <- "NA"
        }
    
    ## Titel als Label priorieren, sonst Bezeichnung einsetzen
    node.labels0 <- ifelse(gliederungseinheit.split$titel != "",
                           gliederungseinheit.split$titel,
                           gliederungseinheit.split$bez)

    ## Rechtsakt als Quelle des Netzwerks einfügen
    node.labels <- c(jurabk,
                     node.labels0)

    
    ## Edgelist erstellen
    edgelist <- f.kennzahlen.edgelist(kennzahl = gliederungseinheit.split$kennzahl,
                                      name = jurabk)



    nodes.df <- data.table(kennzahl,
                           titel)

    addname <- data.table(jurabk,
                          jurabk)

    setnames(addname, new = c("kennzahl",
                              "titel"))

    nodes.df <- rbind(addname,
                      nodes.df)

    setnames(nodes.df, new = c("kennzahl",
                               "label"))


    g  <- graph.data.frame(edgelist,
                           directed = TRUE,
                           vertices = nodes.df)



    M.adjacency <- as.matrix(get.adjacency(g,
                                           edges = F))

    filename <- paste0(gsub("( +)|(/)",
                            "-",
                            jurabk),
                       "_",
                       gsub("\\.xml",
                            "",
                            basename(xml.name)))

    fwrite(edgelist,
           paste0("netzwerke/Edgelists/",
                  filename,
                  "_Edgelist.csv"))

    
    fwrite(M.adjacency,
           paste0("netzwerke/Adjazenzmatrizen/",
                  filename,
                  "_AdjazenzMatrix.csv"))

    write_graph(g,
                file = paste0("netzwerke/GraphML/",
                              filename,
                              ".graphml"),
                format = "graphml")

    if (length(V(g)) > 1){
        
        networkplot <- ggraph(g,
                              'dendrogram',
                              circular = TRUE) + 
            geom_edge_elbow(colour = "grey") + 
            geom_node_text(aes(label = label),
                           size = 2,
                           repel = TRUE)+
            theme_void()+
            labs(
                title = paste(prefix.figuretitle,
                              "| Struktur des",
                              jurabk),
                caption = caption
            )+
            theme(
                plot.title = element_text(size = 50,
                                          face = "bold"),
                legend.position = "none",
                plot.margin = margin(10, 20, 10, 10)
            )

        ## may conflict with markdown save
        ggsave(
            filename = paste0("netzwerke/Netzwerkdiagramme/",
                              filename,
                              "_NetzwerkDiagramm.pdf"),
            plot = networkplot,
            device = "pdf",
            scale = 1,
            width = 50,
            height = 50,
            units = "in",
            dpi = 300,
            limitsize = FALSE
        )
    }

}





#'### Netzwerk-Analyse durchführen

files.xml <- list.files("XML",
                        pattern = "\\.xml$")

errorfiles <- c("BJNR008810961.xml",
                "BJNR010599989.xml",
                "BJNR043410015.xml",
                "BJNR093000015.xml",
                "BJNR135410017.xml",
                "BJNR158720007.xml",
                "BJNR203210978.xml",
                "BJNR203220978.xml",
                "BJNR277700013.xml",
                "BJNR284600017.xml",
                "BJNR364800009.xml",
                "BJNR000939960.xml")

files.xml <- setdiff(files.xml, errorfiles)

files.xml <- paste0("XML/",
                    files.xml)

length(files.xml)


#https://www.gesetze-im-internet.de/bgb/BJNR001950896.epub

#xml.name <- files.xml[205]

xml.name <- "XML/BJNR002089971.xml" # problem
xml.name <- "XML/BJNR001950896.xml" # BGB

#+
#'### Beginn Network Analysis
begin.netanalysis <- Sys.time()


#'### Parallelisierung definieren
#'  Parallele Berechnung funktioniert nicht mit errorfiles; sequentielle Berechnung schon

plan("multicore",
     workers = fullCores)

plan("sequential")


#'### XML Parsen

out.netanalysis <- future_lapply(files.xml,
                                 f.network.analysis,
                                 prefix.figuretitle = prefix.figuretitle,
                                 caption = caption,
                                 future.seed = TRUE)


#'### XML-Dateien bei denen Fehler auftreten

files.xml[grep("error",
               out.netanalysis)]


#'### Ende XML Parsing
end.netanalysis <- Sys.time()

#'### Dauer XML Parsing
end.netanalysis - begin.netanalysis






###
cl <- makeForkCluster(fullCores)
registerDoParallel(cl)

### Sequentielle Berechnung funktioniert auch mit errorfiles
#registerDoSEQ(cl)

out <- foreach(file = files.xml,
               .errorhandling = 'pass') %dopar% {

    f.network.analysis(file)

}

stopCluster(cl)


#'### XML-Dateien bei denen Fehler auftreten

files.xml[grep("error",
               out)]







#'## Wiederverpacken der XML-Dateien
#' Wiederverpacken der gesammelten XML-Dateien in ein einziges Archiv. Wiederverpacken der Anlagen in ein separates Archiv. Die Roh-Daten werden im Anschluss  jeweils gelöscht.


#+
#'### XML-Dateien definieren

files.xml <- list.files("XML",
                        pattern = "\\.xml",
                        full.names = TRUE)


#+
#'### XML-Dateien verpacken

zip(paste0("output/",
          prefix.files,
          "_DE_XML_Datensatz.zip"),
    files.xml,
    mode = "cherry-pick")


#'### Anhänge zu XML-Dateien verpacken

attachments <- list.files("XML",
                          pattern = "(\\.jpg)|(\\.gif)|(\\.pdf)|(\\.png)",
                          ignore.case = TRUE,
                          full.names = TRUE)


if (length(attachments) > 0){

zip(paste0("output/",
          prefix.files,
          "_DE_XML_Anlagen.zip"),
    attachments,
    mode = "cherry-pick")

    }








#'# Frequenztabellen erstellen: Einzelnormen


#+
#'## Funktion anzeigen: f.fast.freqtable

#+ results = "asis"
print(f.fast.freqtable)

#'## Liste zu prüfender Variablen
print(config$freqtable$ignore)


#'## Frequenztabellen erstellen

prefix.freqtable.einzelnormen <- paste0(config$project$shortname,
                                        "_01_Einzelnormen_Frequenztabelle_var-")


#+ results = "asis"
f.fast.freqtable(dt.normen,
                 varlist = config$freqtable$ignore,
                 sumrow = TRUE,
                 output.list = FALSE,
                 output.kable = TRUE,
                 output.csv = TRUE,
                 outputdir = dir.analysis,
                 prefix = prefix.freqtable.einzelnormen)



#'# Frequenztabellen erstellen: Rechtsakte

#'## Variablen ignorieren
#' Folgende Variablen sind wegen der geringeren Auflösung der Metadaten (nur Rechtsaktebene, nicht Normebene) nicht mehr nutzbar:

varremove <- c("gliederungskennzahl")

vars.freqtable.rechtsakte <- grep(paste(varremove,
                                        collapse = "|"),
                               config$freqtable$ignore,
                               invert = TRUE,
                               value = TRUE)



#'## Liste zu prüfender Variablen

print(vars.freqtable.rechtsakte)




#'## Frequenztabellen erstellen

prefix.freqtable.rechtsakte <- paste0(config$project$shortname,
                                      "_01_Rechtsakte_Frequenztabelle_var-")


#+ results = "asis"
f.fast.freqtable(dt.rechtsakte,
                 varlist = vars.freqtable.rechtsakte,
                 sumrow = TRUE,
                 output.list = FALSE,
                 output.kable = TRUE,
                 output.csv = TRUE,
                 outputdir = dir.analysis,
                 prefix = prefix.freqtable.rechtsakte)






#'# Frequenztabellen erstellen: XML-Metadaten


#'## Liste zu prüfender Variablen
print(vars.freqtable.rechtsakte)



#'## Frequenztabellen erstellen

prefix.freqtable.meta <- paste0(config$project$shortname,
                 "_01_Meta_Frequenztabelle_var-")


#+ results = "asis"
f.fast.freqtable(dt.meta,
                 varlist = vars.freqtable.rechtsakte,
                 sumrow = TRUE,
                 output.list = FALSE,
                 output.kable = TRUE,
                 output.csv = TRUE,
                 outputdir = dir.analysis,
                 prefix = prefix.freqtable.meta)









#'# Frequenztabellen visualisieren

#+
#'## Präfixe erstellen

prefix.normen <- paste0(basename(dir.analysis),
                        "/",
                        config$project$shortname,
                        "_01_Einzelnormen_Frequenztabelle_var-")

prefix.rechtsakte <- paste0(basename(dir.analysis),
                            "/",
                            config$project$shortname,
                            "_01_Rechtsakte_Frequenztabelle_var-")

prefix.meta <- paste0(basename(dir.analysis),
                      "/",
                      config$project$shortname,
                      "_01_Meta_Frequenztabelle_var-")



#'## Tabellen für Einzelnormen einlesen

table.normen.periodikum <- fread(paste0(prefix.normen,
                                        "periodikum.csv"))

table.normen.ausjahr <- fread(paste0(prefix.normen,
                                     "ausfertigung_jahr.csv"))



#'## Tabellen für Rechtsakte einlesen

table.rechtsakte.periodikum <- fread(paste0(prefix.rechtsakte,
                                            "periodikum.csv"))

table.rechtsakte.ausjahr <- fread(paste0(prefix.rechtsakte,
                                         "ausfertigung_jahr.csv"))



#'## Tabellen für XML-Metadaten einlesen

table.meta.periodikum <- fread(paste0(prefix.meta,
                                      "periodikum.csv"))

table.meta.ausjahr <- fread(paste0(prefix.meta,
                                   "ausfertigung_jahr.csv"))



#'\newpage
#'## Periodikum


#+
#'### Einzelnormen

freqtable <- table.normen.periodikum[-.N]

#+ C-DBR_02_Einzelnormen_Barplot_Periodikum, fig.height = 10, fig.width = 8
ggplot(data = freqtable)+
    geom_bar(aes(x = reorder(periodikum,
                             N),
                 y = N),
             stat = "identity",
             fill = "black",
             color = "black")+
    coord_flip()+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Einzelnormen je Periodikum"),
        caption = caption,
        x = "Periodikum",
        y = "Einzelnormen"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )


#'\newpage
#+
#'### Rechtsakte

freqtable <- table.rechtsakte.periodikum[-.N]

#+ C-DBR_02_Rechtsakte_Barplot_Periodikum, fig.height = 10, fig.width = 8
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(periodikum,
                             N),
                 y = N),
             stat = "identity",
             fill = "black",
             color = "black") +
    coord_flip()+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Rechtsakte mit Inhalt je Periodikum"),
        caption = caption,
        x = "Periodikum",
        y = "Rechtsakte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#+
#'### XML-Metadaten

freqtable <- table.meta.periodikum[-.N]

#+ C-DBR_02_Meta_Barplot_Periodikum, fig.height = 10, fig.width = 8
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(periodikum,
                             N),
                 y = N),
             stat = "identity",
             fill = "black",
             color = "black") +
    coord_flip()+
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Rechtsakte nach Metadaten je Periodikum"),
        caption = caption,
        x = "Periodikum",
        y = "Rechtsakte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )





#'\newpage
#'## Ausfertigungsjahr


#+
#'### Einzelnormen

freqtable <- table.normen.ausjahr[-.N][,lapply(.SD, as.numeric)]

#+ C-DBR_03_Einzelnormen_Barplot_Ausfertigungsjahr, fig.height = 7, fig.width = 11
ggplot(data = freqtable) +
    geom_bar(aes(x = ausfertigung_jahr,
                 y = N),
             stat = "identity",
             fill = "black")+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Einzelnormen je Ausfertigungsjahr"),
        caption = caption,
        x = "Ausfertigungsjahr",
        y = "Einzelnormen"
    )+
    theme(
        text = element_text(size = 16),
        plot.title = element_text(size = 16,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#+
#'### Rechtsakte

freqtable <- table.rechtsakte.ausjahr[-.N][,lapply(.SD, as.numeric)]

#+ C-DBR_03_Rechtsakte_Barplot_Ausfertigungsjahr, fig.height = 7, fig.width = 11
ggplot(data = freqtable) +
    geom_bar(aes(x = ausfertigung_jahr,
                 y = N),
             stat = "identity",
             fill = "black") +
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Rechtsakte mit Inhalt je Ausfertigungsjahr"),
        caption = caption,
        x = "Ausfertigungsjahr",
        y = "Rechtsakte"
    )+
    theme(
        text = element_text(size = 16),
        plot.title = element_text(size = 16,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )





#'\newpage
#+
#'### XML-Metadaten

freqtable <- table.meta.ausjahr[-.N][,lapply(.SD, as.numeric)]


#+ C-DBR_03_Meta_Barplot_Ausfertigungsjahr, fig.height = 7, fig.width = 11
ggplot(data = freqtable) +
    geom_bar(aes(x = ausfertigung_jahr,
                 y = N),
             stat = "identity",
             fill = "black") +
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Rechtsakte nach Metadaten je Ausfertigungsjahr"),
        caption = caption,
        x = "Ausfertigungsjahr",
        y = "Rechtsakte"
    )+
    theme(
        text = element_text(size = 16),
        plot.title = element_text(size = 16,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )






#'# Korpus-Analytik

#+
#'## Berechnung linguistischer Kennwerte
#' An dieser Stelle werden für jedes Dokument die Anzahl Zeichen, Tokens, Typen und Sätze berechnet und mit den jeweiligen Metadaten verknüpft. Das Ergebnis ist grundsätzlich identisch mit dem eigentlichen Datensatz, nur ohne den Text der Entscheidungen.


#+
#'### Funktion anzeigen:  f.summarize.iterator
print(f.lingsummarize.iterator)



#'### Berechnung durchführen
lingstats.normen.raw <- f.lingsummarize.iterator(dt.normen,
                                                 threads = fullCores,
                                                 chunksize = 1)

lingstats.rechtsakte.raw <- f.lingsummarize.iterator(dt.rechtsakte,
                                                     threads = fullCores,
                                                     chunksize = 1)


#'## Variablen-Namen anpassen

#+
#'### Einzelnormen
setnames(lingstats.normen.raw,
         old = c("nchars",
                 "ntokens",
                 "ntypes",
                 "nsentences"),
         new = c("zeichen",
                 "tokens",
                 "typen",
                 "saetze"))

#'### Rechtsakte
setnames(lingstats.rechtsakte.raw,
         old = c("nchars",
                 "ntokens",
                 "ntypes",
                 "nsentences"),
         new = c("zeichen",
                 "tokens",
                 "typen",
                 "saetze"))


#'## Kennwerte den Korpora hinzufügen

#+
#'### Einzelnormen
dt.normen <- cbind(dt.normen,
                   lingstats.normen.raw)

#'### Rechtsakte
dt.rechtsakte <- cbind(dt.rechtsakte,
                   lingstats.rechtsakte.raw)


#'## Varianten mit Metadaten erstellen

#+
#'### Einzelnormen
meta.normen <- dt.normen[, !"text"]

#'### Rechtsakte
meta.rechtsakte <- dt.rechtsakte[, !"text"]




#'\newpage
#'## Linguistische Kennwerte: Einzelnormen
#' **Hinweis:** Typen sind definiert als einzigartige Tokens und werden hier noch einmal bezogen auf den Gesamtkorpus berechnet, statt wie vorher bezogen auf jedes Dokument.

#+
#'### Zusammenfassungen berechnen

dt.summary.ling <- lingstats.normen.raw[, lapply(.SD,
                                                 function(x)unclass(summary(x))),
                                        .SDcols = c("zeichen",
                                                    "tokens",
                                                    "typen",
                                                    "saetze")]


dt.sums.ling <- lingstats.normen.raw[,
                                     lapply(.SD, sum),
                                     .SDcols = c("zeichen",
                                                 "tokens",
                                                 "typen",
                                                 "saetze")]


tokens.normen <- tokens(corpus(dt.normen),
                      what = "word",
                      remove_punct = FALSE,
                      remove_symbols = FALSE,
                      remove_numbers = FALSE,
                      remove_url = FALSE,
                      remove_separators = TRUE,
                      split_hyphens = FALSE,
                      include_docvars = FALSE,
                      padding = FALSE
                      )


dt.sums.ling$typen <- nfeat(dfm(tokens.normen))




dt.stats.ling <- rbind(dt.sums.ling,
                       dt.summary.ling)

dt.stats.ling <- transpose(dt.stats.ling,
                           keep.names = "names")

setnames(dt.stats.ling, c("Variable",
                          "Sum",
                          "Min",
                          "Quart1",
                          "Median",
                          "Mean",
                          "Quart3",
                          "Max"))

#'\newpage
#'### Zusammenfassungen anzeigen

kable(dt.stats.ling,
      format.args = list(big.mark = ","),
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)


#'### Zusammenfassungen speichern

fwrite(dt.stats.ling,
       paste0(dir.analysis,
              config$project$shortname,
              "_00_Einzelnormen_KorpusStatistik_ZusammenfassungLinguistisch.csv"),
       na = "NA")




#'\newpage
#'## Linguistische Kennwerte: Rechtsakte
#' **Hinweis:** Typen sind definiert als einzigartige Tokens und werden hier noch einmal bezogen auf den Gesamtkorpus berechnet, statt wie vorher bezogen auf jedes Dokument.

#+
#'### Zusammenfassungen berechnen

dt.summary.ling <- lingstats.rechtsakte.raw[, lapply(.SD,
                                                 function(x)unclass(summary(x))),
                                        .SDcols = c("zeichen",
                                                    "tokens",
                                                    "typen",
                                                    "saetze")]


dt.sums.ling <- lingstats.rechtsakte.raw[,
                                     lapply(.SD, sum),
                                     .SDcols = c("zeichen",
                                                 "tokens",
                                                 "typen",
                                                 "saetze")]


tokens.rechtsakte <- tokens(corpus(dt.rechtsakte),
                      what = "word",
                      remove_punct = FALSE,
                      remove_symbols = FALSE,
                      remove_numbers = FALSE,
                      remove_url = FALSE,
                      remove_separators = TRUE,
                      split_hyphens = FALSE,
                      include_docvars = FALSE,
                      padding = FALSE
                      )


dt.sums.ling$typen <- nfeat(dfm(tokens.rechtsakte))




dt.stats.ling <- rbind(dt.sums.ling,
                       dt.summary.ling)

dt.stats.ling <- transpose(dt.stats.ling,
                           keep.names = "names")

setnames(dt.stats.ling, c("Variable",
                          "Sum",
                          "Min",
                          "Quart1",
                          "Median",
                          "Mean",
                          "Quart3",
                          "Max"))

#'\newpage
#'### Zusammenfassungen anzeigen

kable(dt.stats.ling,
      format.args = list(big.mark = ","),
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)


#'### Zusammenfassungen speichern

fwrite(dt.stats.ling,
       paste0(dir.analysis,
              config$project$shortname,
              "_00_Rechtsakte_KorpusStatistik_ZusammenfassungLinguistisch.csv"),
       na = "NA")










#'\newpage
#'## Verteilungen


#+
#'### Density (Zeichen)

#+ C-DBR_04_Einzelnormen_Density_Zeichen, fig.height = 6, fig.width = 9
ggplot(data = meta.normen)+
    geom_density(aes(x = zeichen),
                 fill = "black") +
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+ 
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Zeichen je Norm"),
        caption = caption,
        x = "Zeichen",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#+ C-DBR_04_Rechtsakte_Density_Zeichen, fig.height = 6, fig.width = 9
ggplot(data = meta.rechtsakte)+
    geom_density(aes(x = zeichen),
                 fill = "black") +
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+ 
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Zeichen je Rechtsakt"),
        caption = caption,
        x = "Zeichen",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#+
#'### Density (Tokens)

#+ C-DBR_05_Einzelnormen_Density_Tokens, fig.height = 6, fig.width = 9
ggplot(data = meta.normen)+
    geom_density(aes(x = tokens),
                 fill = "black") +
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+ 
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Tokens je Norm"),
        caption = caption,
        x = "Tokens",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )




#'\newpage
#+ C-DBR_05_Rechtsakte_Density_Tokens, fig.height = 6, fig.width = 9
ggplot(data = meta.rechtsakte)+
    geom_density(aes(x = tokens),
                 fill = "black")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+ 
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Tokens je Rechtsakt"),
        caption = caption,
        x = "Tokens",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )






#'\newpage
#'### Density (Typen)

#+ C-DBR_06_Einzelnormen_Density_Typen, fig.height = 6, fig.width = 9
ggplot(data = meta.normen)+
    geom_density(aes(x = typen),
                 fill = "black")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+ 
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Typen je Norm"),
        caption = caption,
        x = "Typen",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#+ C-DBR_06_Rechtsakte_Density_Typen, fig.height = 6, fig.width = 9
ggplot(data = meta.rechtsakte)+
    geom_density(aes(x = typen),
                 fill = "black")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+ 
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Typen je Rechtsakt"),
        caption = caption,
        x = "Typen",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )






#'\newpage
#'### Density (Sätze)

#+ C-DBR_07_Einzelnormen_Density_Saetze, fig.height = 6, fig.width = 9
ggplot(data = meta.normen)+
    geom_density(aes(x = saetze),
                 fill = "black")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+ 
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Sätze je Norm"),
        caption = caption,
        x = "Sätze",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )





#'\newpage
#+ C-DBR_07_Rechtsakte_Density_Saetze, fig.height = 6, fig.width = 9
ggplot(data = meta.rechtsakte)+
    geom_density(aes(x = saetze),
                 fill = "black")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+ 
    coord_cartesian(xlim = c(1, 10^6))+ 
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Sätze je Rechtsakt"),
        caption = caption,
        x = "Sätze",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )






#'## Quantitative Variablen

#+
#'### Ausfertigungsdatum

#' ***Einzelnormen***
summary(as.IDate(dt.normen$ausfertigung_datum))

#' ***Rechtsakte***
summary(as.IDate(dt.rechtsakte$ausfertigung_datum))

#' ***XML-Metadaten***
summary(as.IDate(dt.meta$ausfertigung_datum))



#'### Ausfertigungsjahr

#' ***Einzelnormen***
summary(dt.normen$ausfertigung_jahr)

#' ***Rechtsakte***
summary(dt.rechtsakte$ausfertigung_jahr)

#' ***XML-Metadaten***
summary(dt.meta$ausfertigung_jahr)






#'# Strenge Kontrolle der Variablen-Namen

#+
#'## Semantische Sortierung der Variablen

#+
#'### Variablen sortieren: Einzelnormen


setcolorder(dt.normen,
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

#'\newpage
setcolorder(meta.normen,
            c("doc_id",
              "dateiname",
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

#'\newpage
#'### Variablen sortieren: Rechtsakte

setcolorder(dt.rechtsakte,
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

#'\newpage
setcolorder(meta.rechtsakte,
            c("doc_id",
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


#'\newpage
#'### Variablen sortieren: XML-Metadaten

setcolorder(dt.meta,
            c("doc_id",
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
              "builddate_original",
              "builddate_iso",
              "doi_concept",
              "doi_version",
              "version",
              "lizenz"))





#'## Anzahl Variablen der Datensätze

length(dt.normen)

length(meta.normen)

length(dt.rechtsakte)

length(meta.rechtsakte)

length(dt.meta)


#'## Alle Variablen-Namen der Datensätze

names(dt.normen)

names(meta.normen)

names(dt.rechtsakte)

names(meta.rechtsakte)

names(dt.meta)









#'# CSV-Dateien erstellen

#+
#'## Einzelnormen (Korpus)

#+
#'### Name für CSV definieren

csvname.normen.gesamt <- paste0(prefix.files,
                               "_DE_CSV_Einzelnormen_Datensatz.csv")

#'### Datensatz speichern

fwrite(dt.normen,
       paste0("output/",
              csvname.normen.gesamt),
       na = "NA")


#+
#'## Einzelnormen (Metadaten)

#+
#'### Name für CSV definieren

csvname.normen.meta <- paste0(prefix.files,
                             "_DE_CSV_Einzelnormen_Metadaten.csv")

#'### Datensatz speichern

fwrite(meta.normen,
       paste0("output/",
              csvname.normen.meta),
       na = "NA") 




#'## Rechtsakte (Korpus)

#+
#'### Name für CSV definieren

csvname.rechtsakte.gesamt <- paste0(prefix.files,
                                   "_DE_CSV_Rechtsakte_Datensatz.csv")

#'### Datensatz speichern

fwrite(dt.rechtsakte,
       paste0("output/",
              csvname.rechtsakte.gesamt),
       na = "NA") 



#'## Rechtsakte (Metadaten)

#+
#'### Name für CSV definieren

csvname.rechtsakte.meta <- paste0(prefix.files,
                                 "_DE_CSV_Rechtsakte_Metadaten.csv")


#'### Datensatz speichern

fwrite(meta.rechtsakte,
       paste0("output/",
              csvname.rechtsakte.meta),
       na = "NA") 





#'## XML-Metadaten
#' Diese Datei unterscheidet sich von der Variante "DE_CSV_Rechtsakte_Metadaten", weil sie auch Rechtsakte enthält, die ohne Text veröffentlicht wurden. Die Differenz betrifft etwa 1000 Rechtsakte, ist also erheblich.

#+
#'### Name für CSV definieren

csvname.meta <- paste0(prefix.files,
                      "_DE_CSV_MetadatenXML.csv")


#'### Datensatz speichern

fwrite(dt.meta,
       paste0("output/",
              csvname.meta),
       na = "NA")







#'# Download der PDF-Dateien

#+
#'## Download durchführen

#+ results = 'hide'
mcmapply(download.file,
         download$links.pdf,
         paste0("PDF/",
                download$title.pdf))


#'## Download-Ergebnis

#+
#'### Anzahl herunterzuladender Dateien
download[,.N]

#'### Anzahl heruntergeladener Dateien
files.pdf <- list.files("PDF",
                        pattern = "\\.pdf")
length(files.pdf)

#'### Fehlbetrag
N.missing <- download[,.N] - length(files.pdf)
print(N.missing)

#'### Fehlende Dateien
missing <- setdiff(download$title.pdf,
                   files.pdf)
print(missing)





#'# TXT-Dateien erstellen
#' An dieser Stelle wird der reine Text aus den PDF-Dateien extrahiert und ein zusätzliches Datei-Format (TXT) generiert. TXT-Dateien sind besonders für quantitative Analysten ohne XML-Kenntnisse ein lohnenswerter Einstieg und verringern die Hürde für die Arbeit mit dem Korpus.

files.pdf <- list.files("PDF",
                        pattern = "\\.pdf",
                        ignore.case = TRUE,
                        full.names = TRUE)


#'## Anzahl zu extrahierender Dateien
length(files.pdf)


#'## Funktion anzeigen: f.dopar.pagenums
#+ results = "asis"
print(f.dopar.pagenums)


#'## Anzahl zu extrahierender Seiten
sum(f.dopar.pagenums(files.pdf))


#'## Funktion anzeigen: f.dopar.pdfextract
#+ results = "asis"
print(f.dopar.pdfextract)


#'## Text Extrahieren
#+ results = "hide"
f.dopar.pdfextract(files.pdf)


#'## TXT-Dateien in separaten Ordner verschieben

files.txt <- list.files("PDF",
                        pattern = "\\.txt",
                        ignore.case = TRUE,
                        full.names = TRUE)

files.txt.destination <- gsub("PDF/",
                              "TXT/",
                              files.txt)

file.rename(files.txt,
            files.txt.destination)




#'# Download der EPUB-Dateien

#+
#'## Download durchführen

#+ results = 'hide'
mcmapply(download.file,
         download$links.epub,
         paste0("EPUB/",
                download$title.epub))




#'## Download-Ergebnis

#+
#'### Anzahl herunterzuladender Dateien
download[,.N]

#'### Anzahl heruntergeladener Dateien
files.epub <- list.files("EPUB",
                         pattern = "\\.epub")
length(files.epub)

#'### Fehlbetrag
N.missing <- download[,.N] - length(files.epub)
print(N.missing)

#'### Fehlende Dateien
missing <- setdiff(download$title.epub, files.epub)
print(missing)






#'# Dateigrößen analysieren

files.txt <- list.files("TXT",
                        pattern = "\\.txt$",
                        ignore.case = TRUE,
                        full.names = TRUE)

files.pdf <- list.files("PDF",
                        pattern = "\\.pdf$",
                        ignore.case = TRUE,
                        full.names = TRUE)

files.epub <- list.files("EPUB",
                         pattern = "\\.epub$",
                         ignore.case = TRUE,
                         full.names = TRUE)


txt.MB <- file.size(files.txt) / 10^6
pdf.MB <- file.size(files.pdf) / 10^6
epub.MB <- file.size(files.epub) / 10^6



#'## Gesamtgröße

#+
#'### PDF-Dateien (MB)
sum(pdf.MB)

#'### EPUB-Dateien (MB)
sum(epub.MB)

#'### XML-Dateien (MB)
sum(xml.MB)

#'### TXT-Dateien (MB)
sum(txt.MB)


#'### Objekte in RAM (MB)

print(object.size(dt.normen),
      standard = "SI",
      humanReadable = TRUE,
      units = "MB")

print(object.size(dt.rechtsakte),
      standard = "SI",
      humanReadable = TRUE,
      units = "MB")

print(object.size(dt.meta),
      standard = "SI",
      humanReadable = TRUE,
      units = "MB")



#'\newpage
#'## Verteilung der Dateigrößen (PDF)

dt.plot <- data.table(pdf.MB)


#+ C-DBR_08_Density_Dateigroessen_PDF, fig.height = 6, fig.width = 9
ggplot(data = dt.plot,
       aes(x = pdf.MB))+
    geom_density(fill = "black")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Dateigrößen (PDF)"),
        caption = caption,
        x = "Dateigröße in MB",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )




#'\newpage
#'## Verteilung der Dateigrößen (EPUB)

dt.plot <- data.table(epub.MB)


#+ C-DBR_09_Density_Dateigroessen_EPUB, fig.height = 6, fig.width = 9
ggplot(data = dt.plot,
       aes(x = epub.MB))+
    geom_density(fill = "black")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Dateigrößen (EPUB)"),
        caption = caption,
        x = "Dateigröße in MB",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )





#'\newpage
#'## Verteilung der Dateigrößen (XML)

dt.plot <- data.table(xml.MB)


#+ C-DBR_10_Density_Dateigroessen_XML, fig.height = 6, fig.width = 9
ggplot(data = dt.plot,
       aes(x = xml.MB))+
    geom_density(fill = "black")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Dateigrößen (XML)"),
        caption = caption,
        x = "Dateigröße in MB",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## Verteilung der Dateigrößen (TXT)

dt.plot <- data.table(txt.MB)


#+ C-DBR_11_Density_Dateigroessen_TXT, fig.height = 6, fig.width = 9
ggplot(data = dt.plot,
       aes(x = txt.MB))+
    geom_density(fill = "black")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Dateigrößen (TXT)"),
        caption = caption,
        x = "Dateigröße in MB",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )








#'# ZIP-Archive erstellen

#+
#'## Verpacken der CSV-Dateien

files.csv <- c(csvname.normen.gesamt,
               csvname.normen.meta,
               csvname.rechtsakte.gesamt,
               csvname.rechtsakte.meta,
               csvname.meta)

files.csv <- paste0("output/",
                    files.csv)

csvnames.zip <- gsub(".csv",
                     ".zip",
                     files.csv)

for (i in seq_along(files.csv)){
    zip(csvnames.zip[i],
        files.csv[i],
    mode = "cherry-pick")
}

unlink(files.csv)



#'## Verpacken der PDF-Dateien

files.pdf <- list.files("PDF",
                        pattern = "\\.pdf$",
                        ignore.case = TRUE,
                        full.names = TRUE)

zip(paste0("output/",
           prefix.files,
           "_DE_PDF_Datensatz.zip"),
    files.pdf,
    mode = "cherry-pick")






#'## Verpacken der TXT-Dateien

files.txt <- list.files("TXT",
                        pattern = "\\.txt$",
                        ignore.case = TRUE,
                        full.names = TRUE)

zip(paste0("output/",
           prefix.files,
           "_DE_TXT_Datensatz.zip"),
    files.txt,
    mode = "cherry-pick")





#'## Verpacken der EPUB-Dateien

files.epub <- list.files("EPUB",
                         pattern = "\\.epub$",
                         ignore.case = TRUE,
                         full.names = TRUE)

zip(paste0("output/",
           prefix.files,
           "_DE_EPUB_Datensatz.zip"),
    files.epub,
    mode = "cherry-pick")




#'## Verpacken der Netzwerk-Dateien

zip(paste0("output/",
           prefix.files,
           "_DE_Netzwerke.zip"),
    "netzwerke",
    mode = "cherry-pick")




#'## Verpacken der Analyse-Dateien

zip(paste0("output/",
           prefix.files,
           "_DE_",
           toupper(basename(dir.analysis)),
           ".zip"),
    basename(dir.analysis),
    mode = "cherry-pick")




#'## Verpacken der Source-Dateien

files.source <- c(list.files(pattern = "\\.R$|\\.toml$"),
                  "R-fobbe-proto-package",
                  "functions",
                  "tex",
                  "buttons")


files.source <- grep("spin",
                     files.source,
                     value = TRUE,
                     ignore.case = TRUE,
                     invert = TRUE)

zip(paste0("output/",
          prefix.files,
          "_Source_Code.zip"),
    files.source,
    mode = "cherry-pick")



#'# Aufräumen
#' An dieser Stelle werden die Ordner mit den Roh-Dateien gelöscht.


unlink("XML", recursive = TRUE)
unlink("PDF", recursive = TRUE)
unlink("TXT", recursive = TRUE)
unlink("EPUB", recursive = TRUE)

unlink("netzwerke", recursive = TRUE)
unlink("Rplots.pdf", recursive = TRUE)




#'# Kryptographische Hashes
#' Dieses Modul berechnet für jedes ZIP-Archiv zwei Arten von Hashes: SHA2-256 und SHA3-512. Mit diesen kann die Authentizität der Dateien geprüft werden und es wird dokumentiert, dass sie aus diesem Source Code hervorgegangen sind. Die SHA-2 und SHA-3 Algorithmen gelten derzeit als sicher und ein SHA3-Hash mit 512 bit Länge ist nach derzeitigem Wissen auch gegenüber quantenkryptoanalytischen Verfahren hinreichend resistent.

#+
#'## Liste der ZIP-Archive erstellen
files.zip <- list.files("output",
                        pattern = "\\.zip$",
                        ignore.case = TRUE,
                        full.names = TRUE)



#'## Funktion anzeigen: f.dopar.multihashes
#+ results = "asis"
print(f.dopar.multihashes)


#'## Hashes berechnen
multihashes <- f.dopar.multihashes(files.zip)


#'## In Data Table umwandeln
setDT(multihashes)



#'## Index hinzufügen
multihashes$index <- seq_len(multihashes[,.N])


#'## Hashes in CSV-Datei speichern
fwrite(multihashes,
       paste0("output/",
              prefix.files,
              "_KryptographischeHashes.csv"),
       na = "NA")


#'## Leerzeichen hinzufügen um Zeilenumbruch zu ermöglichen
multihashes$sha3.512 <- paste(substr(multihashes$sha3.512, 1, 64),
                              substr(multihashes$sha3.512, 65, 128))


#'\newpage
#'## In Bericht anzeigen

kable(multihashes[,.(index,filename)],
      format = "latex",
      align = c("p{1cm}", "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)



#'\newpage
kable(multihashes[,.(index,sha2.256)],
      format = "latex",
      align = c("c", "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)



#'\newpage
kable(multihashes[,.(index,sha3.512)],
      format = "latex",
      align = c("c", "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)







#'# Abschluss


#+
#'## Datumsstempel
print(datestamp)


#'## Datum und Uhrzeit (Anfang)
print(begin.script)

#'## Datum und Uhrzeit (Ende)
end.script <- Sys.time()
print(end.script)

#'## Laufzeit des gesamten Skripts
print(end.script - begin.script)


#'## Warnungen
warnings()



#'# Parameter für strenge Replikationen

system2("openssl", "version", stdout = TRUE)

sessionInfo()


#'# Literaturverzeichnis








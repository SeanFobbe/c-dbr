#'---
#'title: "Codebook | Corpus des Deutschen Bundesrechts"
#'author: Seán Fobbe
#'geometry: margin=3cm
#'fontsize: 11pt
#'papersize: a4
#'output:
#'  pdf_document:
#'    toc: true
#'    toc_depth: 3
#'    number_sections: true
#'    pandoc_args: --listings
#'    includes:
#'      in_header: tex/Preamble_DE.tex
#'      before_body: [temp/C-DBR_Definitions.tex, tex/C-DBR_CodebookTitle.tex]
#'bibliography: temp/packages.bib
#'nocite: '@*'
#' ---

#'\newpage

#+ echo = FALSE 
knitr::opts_chunk$set(fig.pos = "center",
                      echo = FALSE,
                      warning = FALSE,
                      message = FALSE)


############################
### Packages
############################

#+

library(RcppTOML)     # Verarbeitung von TOML-Format
library(knitr)        # Professionelles Reporting
library(kableExtra)   # Verbesserte automatisierte Tabellen
library(magick)       # Fortgeschrittene Verarbeitung von Grafiken
library(parallel)     # Parallelisierung in Base R
library(ggplot2)      # Fortgeschrittene Datenvisualisierung
library(scales)       # Skalierung von Diagrammen
library(data.table)   # Fortgeschrittene Datenverarbeitung

setDTthreads(threads = detectCores()) 



############################
### Vorbereitung
############################


## Konfiguration einlesen
config <- parseTOML("C-DBR_Config.toml")



## Datumsstempel einlesen

files.zip <- list.files("output",
                        pattern = "\\.zip")

datestamp <- unique(tstrsplit(files.zip,
                              split = "_")[[2]])





############################
### Tabellen einlesen
############################

## Präfixe erstellen

prefix.date <- paste0("output/",
                      config$project$shortname,
                      "_",
                      datestamp)

prefix.normen <- paste0("analyse/",
                        config$project$shortname,
                        "_01_Einzelnormen_Frequenztabelle_var-")

prefix.rechtsakte <- paste0("analyse/",
                            config$project$shortname,
                            "_01_Rechtsakte_Frequenztabelle_var-")

prefix.meta <- paste0("analyse/",
                      config$project$shortname,
                      "_01_Meta_Frequenztabelle_var-")


## Tabellen für Einzelnormen einlesen

table.normen.periodikum <- fread(paste0(prefix.normen,
                                        "periodikum.csv"))

table.normen.ausjahr <- fread(paste0(prefix.normen,
                                     "ausfertigung_jahr.csv"))


## Tabellen für Rechtsakte einlesen

table.rechtsakte.periodikum <- fread(paste0(prefix.rechtsakte,
                                            "periodikum.csv"))

table.rechtsakte.ausjahr <- fread(paste0(prefix.rechtsakte,
                                         "ausfertigung_jahr.csv"))


## Tabellen für Metadaten einlesen

table.meta.periodikum <- fread(paste0(prefix.meta,
                                      "periodikum.csv"))

table.meta.ausjahr <- fread(paste0(prefix.meta,
                                   "ausfertigung_jahr.csv"))


## Linguistische Kennzahlen einlesen

stats.rechtsakte.ling <-  fread(paste0("analyse/",
                                       config$project$shortname,
                                       "_00_Rechtsakte_KorpusStatistik_ZusammenfassungLinguistisch.csv"))

stats.normen.ling <-  fread(paste0("analyse/",
                                   config$project$shortname,
                                   "_00_Einzelnormen_KorpusStatistik_ZusammenfassungLinguistisch.csv"))


meta.normen <- fread(cmd = paste0("unzip -cq ",
                                  prefix.date,
                                  "_DE_CSV_Einzelnormen_Metadaten.zip"))

meta.rechtsakte <- fread(cmd = paste0("unzip -cq ",
                                  prefix.date,
                                  "_DE_CSV_Rechtsakte_Metadaten.zip"))





############################
### Signaturen bestimmen
############################


hashfile <- paste(prefix.date,
                  "KryptographischeHashes.csv",
                  sep = "_")

signaturefile <- paste(prefix.date,
                       "FobbeSignaturGPG_Hashes.gpg",
                       sep = "_")





################################
### Beginn Text
################################





#'# Einführung

#' Dem **Bundesrecht** kommt im Normengefüge der Bundesrepublik Deutschland herausragende Bedeutung zu. Zwar sind die Länder gemäß Art. 30, 70 GG primär für die Gesetzgebung zuständig, im Katalog der Art. 71 ff GG sind aber derart viele Kompetenzen dem Bund zugewiesen, dass das Bundesrecht praktisch jedes rechtliche Problem in der Bundesrepublik dominiert. Ausnahmen sind in der Regel nur die Bereiche innere Sicherheit, Bildung und Kultur, die weitgehend in der Hand der Bundesländer verblieben sind. Aber auch in diesen Bereichen finden sich Regelungen des Bundes. Beispiele dafür sind manche Regelungen des Bundespolizeigesetzes (BPolG) oder das Kulturgutschutzgesetz (KGSG).
#'
#' Bundesgesetze werden vom Bundestag im Zusammenwirken mit dem Bundesrat erlassen und vom Bundespräsidenten ausgefertigt (Art. 76 ff GG). Das Initiativrecht liegt bei Abgeordneten aus der Mitte des Bundestags, der Bundesregierung und dem Bundesrat (Art. 76 Abs. 1 GG). Der Bundesrat ist je nach Gesetzescharakter mit einem Zustimmungserfordernis oder einem Einspruchsrecht beteiligt (Art. 77, 78 GG).
#'
#' Verordnungen werden in der Regel von der Exekutive erlassen, in seltenen Fällen vom Bundestag selbst. Durch Bundesgesetz können nur Bundesregierung, Bundesminister oder Landesregierungen hierzu ermächtigt werden (Art. 80 Abs. 1 S.1 GG), eine im Gesetz vorgesehen Sub-Delegation ist aber möglich (Art. 80 Abs. 1 S. 4 GG). Verordnungen müssen einem speziellen Bestimmtheitsgebot genügen und ihre Rechtsgrundlage in der Verordnung angeben (Art. 80 Abs. 1 S. 2 und 3). Der Erlass von Verordnungen erfordert zudem nicht selten die Zustimmung des Bundesrates, entweder aufgrund von Art. 80 Abs. 2 GG oder bedingt durch eine Regelung in einem einfachen Bundesgesetz.
#' 
#'Die quantitative Analyse von juristischen Texten, insbesondere von Gesetzen und Verordnungen, ist in den deutschen Rechtswissenschaften ein noch junges und kaum bearbeitetes Feld.\footnote{Positive Ausnahmen finden sich vor allem unter: \url{https://www.quantitative-rechtswissenschaft.de/}} Zu einem nicht unerheblichen Teil liegt dies auch daran, dass die Anzahl an frei nutzbaren Datensätzen außerordentlich gering ist.
#' 
#'Die meisten hochwertigen Datensätze lagern (fast) unerreichbar in kommerziellen Datenbanken und sind wissenschaftlich gar nicht oder nur gegen Entgelt zu nutzen. Frei verfügbare Datenbanken wie \emph{Opinio Iuris}\footnote{\url{https://opinioiuris.de/}} und \emph{openJur}\footnote{\url{https://openjur.de/}} verbieten ausdrücklich das maschinelle Auslesen der Rohdaten.\footnote{Openjur beabsichtigt eine API anzubieten, diese war aber im Januar 2021 immernoch nicht verfügbar. Openjur ist seit 2008 in Betrieb.} Wissenschaftliche Initiativen wie der Juristische Referenzkorpus (JuReKo) sind nach jahrelanger Arbeit hinter verschlossenen Türen verschwunden.
#' 
#'In einem funktionierenden Rechtsstaat muss die Rechtsetzung öffentlich, transparent und nachvollziehbar sein. Im 21. Jahrhundert bedeutet dies auch, dass sie quantitativen Analysen zugänglich sein muss. Der Erstellung und Aufbereitung des Datensatzes liegen daher die Prinzipien der allgemeinen Verfügbarkeit durch Urheberrechtsfreiheit, strenge Transparenz und vollständige wissenschaftliche Reproduzierbarkeit zugrunde. Die FAIR-Prinzipien (Findable, Accessible, Interoperable and Reusable) für freie wissenschaftliche Daten inspirieren sowohl die Konstruktion, als auch die Art der Publikation.\footnote{Wilkinson, M., Dumontier, M., Aalbersberg, I. et al. The FAIR Guiding Principles for Scientific Data Management and Stewardship. Sci Data 3, 160018 (2016). \url{https://doi.org/10.1038/sdata.2016.18}}




#+
#'# Nutzung

#' Die Daten sind in offenen, interoperablen und weit verbreiteten Formaten (CSV, XML, TXT, PDF, EPUB) veröffentlicht. Sie lassen sich grundsätzlich mit allen modernen Programmiersprachen (z.B. Python oder R), sowie mit grafischen Programmen nutzen.
#'
#' **Wichtig:** Nicht vorhandene Werte sind sowohl in den Dateinamen als auch in der CSV-Datei mit \enquote{NA} codiert.

#+
#'## CSV-Dateien
#' Am einfachsten ist es die **CSV-Dateien** einzulesen. Die Nutzung der CSV-Varianten ist aus Qualitätsgründen und den umfangreicheren Metadaten \emph{empfohlen}. CSV\footnote{Das CSV-Format ist in RFC 4180 definiert, siehe \url{https://tools.ietf.org/html/rfc4180}} ist ein einfaches und maschinell gut lesbares Tabellen-Format. In diesem Datensatz sind die Werte komma-separiert. Jede Spalte entspricht einer Variable, jede Zeile einer Einzelnorm bzw. einem Rechtsakt (je nach Variante). Die Variablen sind unter Punkt \ref{variablen} genauer erläutert.
#'
#' Hier empfehle ich für **R** das package **data.table** (via CRAN verfügbar). Dessen Funktion **fread()** ist etwa zehnmal so schnell wie die normale **read.csv()**-Funktion in Base-R. Sie erkennt auch den Datentyp von Variablen sicherer. Ein Beispiel:

#+ eval = FALSE, echo = TRUE
library(data.table)
csv.dbr <- fread("filename.csv")


#+
#'## XML-Dateien
#' Das Einlesen der **XML-Rohdaten** ist komplex und die Entscheidung welche XML-Nodes zu extrahieren sind wird ganz erheblich von der Forschungsfrage beeinflusst. Falls Sie über vertiefte XML-Kenntnisse verfügen, sollten Sie eine eigenständige Extraktion dennoch in Erwägung ziehen, weil sie so die Datenanalyse besser auf Ihre Bedürfnisse anpassen können. Lesen Sie hierfür bitte die Document Type Definition (DTD) genau und greifen Sie ggf. auf den im Source Code zur Verfügung gestellten XML Parser zurück.



#+
#'## TXT-Dateien
#' Die TXT-Dateien enthalten nur sehr rudimentäre Metadaten! Benutzen Sie daher für statistische Analysen vorzugsweise die CSV- oder XML-Dateien. Die **TXT-Dateien** inklusive Metadaten können zum Beispiel mit **R** und dem package **readtext** (via CRAN verfügbar) eingelesen werden. Ein Vorschlag:

#+ eval = FALSE, echo = TRUE
library(readtext)
txt.dbr <- readtext("./*.txt",
                    docvarsfrom = "filenames", 
                    docvarnames = c("kurztitel",
                                    "langtitel"),
                    dvsep = "_", 
                    encoding = "UTF-8")






#+
#'# Konstruktion


#+
#'## Beschreibung des Datensatzes
#' Der Datensatz ist eine möglichst vollständige Sammlung der konsolidierten Fassungen aller Gesetze und Verordnungen auf Bundesebene. Änderungsgesetze und -verordnungen sind nicht enthalten. Er enthält alle Rechtsakte, die auf der amtlichen Webseite \enquote{Gesetze im Internet} des Bundesministerium des Justiz am jeweiligen Stichtag verfügbar waren. Die Stichtage für jede Version sind in der Versionsnummer festgehalten.
#'
#'Zusätzlich zu den einfach maschinenlesbaren Formaten (CSV und TXT) sind die XML-, PDF- und EPUB-Rohdaten enthalten, damit Analysten gegebenenfalls ihre eigene Konvertierung vornehmen können. Die Rohdaten wurden inhaltlich nicht verändert. Die PDF- und EPUB-Varianten der Rechtsakte sollen primär traditionelle juristische Forschung und \emph{mixed methods}-Ansätze unterstützen.
#'
#' In diesem Datensatz sind nur Rechtsakte mit Außenwirkung (d.h. das Grundgesetz, Bundesgesetze und Bundesverordnungen) enthalten. Verwaltungsvorschriften sind nicht Teil des Datensatzes.



#+
#'## Datenquellen

#'\begin{centering}
#'\begin{longtable}{P{5cm}p{9cm}}

#'\toprule

#' Datenquelle & Fundstelle \\

#'\midrule

#' Primäre Datenquelle & \url{https://www.gesetze-im-internet.de/}\\
#' Source Code & \url{\softwareversionurldoi}\\

#'\bottomrule

#'\end{longtable}
#'\end{centering}



#+
#'## Sammlung der Daten
#'Die Daten wurden vollautomatisiert gesammelt und mit Abschluss der Verarbeitung kryptographisch signiert. Die Webseite des Justizministeriums ist laut dem Reiter \enquote{Hinweise}\footnote{\url{https://www.gesetze-im-internet.de/hinweise.html}} ausdrücklich für die vollautomatisierte Datensammlung freigegeben. Der Abruf geschieht ausschließlich über TLS-verschlüsselte Verbindungen.
#'

#+
#'## Source Code und Compilation Report
#' Der gesamte Source Code --- sowohl für die Erstellung des Datensatzes, als auch für dieses Codebook --- ist öffentlich einsehbar und dauerhaft erreichbar im wissenschaftlichen Archiv des CERN unter dieser Addresse hinterlegt: \softwareversionurldoi
#'
#' Mit jeder Kompilierung des vollständigen Datensatzes wird auch ein umfangreicher **Compilation Report** in einem attraktiv designten PDF-Format erstellt (ähnlich diesem Codebook). Der Compilation Report enthält den vollständigen Source Code, dokumentiert relevante Rechenergebnisse, gibt sekundengenaue Zeitstempel an und ist mit einem klickbaren Inhaltsverzeichnis versehen. Er ist zusammen mit dem Source Code hinterlegt. Wenn Sie sich für Details des Erstellungs-Prozesses interessieren, lesen Sie diesen bitte zuerst.



#+
#'## Grenzen des Datensatzes
#'Nutzer sollten folgende wichtige Grenzen beachten:
#' 
#'\begin{enumerate}
#'\item Der Datensatz enthält nur das, was das Bundesjustizministerium auch tatsächlich veröffentlicht (\emph{publication bias}). Es fehlen insbesondere Änderungsgesetze und -verordnungen. Manche Rechtsakte sind zudem nur mit den Metadaten nachgewiesen --- ihr Inhalt fehlt aus technischen Gründen oder weil in der Bereinigten Sammlung Bundesgesetzblatt Teil III nur bibliographische Angaben enthalten sind (§ 3 Abs. 2 BRSG).\footnote{\url{https://www.gesetze-im-internet.de/hinweise.html}}
#'\item Es kann aufgrund technischer Grenzen bzw. Fehler sein, dass manche --- im Grunde verfügbare --- Rechtsakte nicht oder nicht korrekt abgerufen werden (\emph{automation bias}).
#'\item Es sind nur am Tag des Abrufs veröffentlichte konsolidierte Rechtsakte enthalten, eine diachronische Untersuchung muss somit mehrere verfügbare Versionen auswerten (\emph{temporal bias}). 
#'\end{enumerate}


#+
#'## Urheberrechtsfreiheit von Rohdaten und Datensatz 

#'An den Rechtsakten und Rechtsnormen besteht gem. § 5 Abs. 1 UrhG kein Urheberrecht, da sie amtliche Werke sind. § 5 UrhG ist auf amtliche Datenbanken analog anzuwenden (BGH, Beschluss vom 28.09.2006, I ZR 261/03, \enquote{Sächsischer Ausschreibungsdienst}).
#'
#' Alle eigenen Beiträge (z.B. durch Zusammenstellung und Anpassung der Metadaten) und damit den gesamten Datensatz stelle ich gemäß einer \emph{CC0 1.0 Universal Public Domain Lizenz} vollständig urheberrechtsfrei.



#+
#'## Metadaten

#'Alle Metadaten wurden aus den XML-Rohdaten zeitgleich mit dem Text der Normen extrahiert. Der volle Satz an Metadaten ist nur in den CSV-Dateien enthalten. Bitte beachten Sie, dass bei weitem nicht alle XML-Nodes ausgewertet wurden. Viele Nodes enthalten nur optische Informationen und wurden deshalb ignoriert. Manche Nodes (z.B. einzelne Absätze, Listen) wurden nicht extrahiert, weil nicht alle Normen in Absätze und Listen unterteilt sind und die Bereitstellung in einem nicht-hierarchischen Format wie CSV keine Vorteile gegenüber dem XML-Format bringen würde.
#' 
#'Die Dateinamen der PDF-, TXT und EPUB-Dateien enthalten nur eine Abkürzung und einen modifizierten Langtitel (auf 200 Zeichen gekürzt und um Sonderzeichen bereinigt). Diese wurden aus den jeweiligen Header-Markierungen der HTML-Seiten extrahiert.


#+
#'### Schema für die Dateinamen (PDF, TXT, EPUB)

#'\begin{verbatim}
#'[Abkürzung]_[modifizierter_Langtitel]
#'\end{verbatim}

#+
#'### Beispiel eines Dateinamens

#'\begin{verbatim}
#'2.WasSV_ZweiteWassersicherstellungsverordnung.pdf
#'\end{verbatim}

#+
#'## Qualitätsprüfung

#'Insgesamt werden zusammen mit jeder Kompilierung Dutzende Tests zur Qualitätsprüfung durchgeführt. Alle Ergebnisse der Qualitätsprüfungen sind aggregiert im Compilation Report und einzeln im Archiv \enquote{analyse} zusammen mit dem Datensatz veröffentlicht.






#+
#'# Varianten und Zielgruppen

#' Dieser Datensatz ist in verschiedenen Varianten verfügbar, die sich an unterschiedliche Zielgruppen richten. Zielgruppe sind nicht nur quantitativ forschende RechtswissenschaftlerInnen, sondern auch traditionell arbeitende JuristInnen. Idealerweise müssen quantitative Methoden ohnehin immer durch qualitative Interpretation, Bildung von Theorien und kritische Auseinandersetzung verstärkt werden (\emph{mixed methods approach}).
#'
#' Lehrende werden zudem von den vorbereiteten Tabellen und Diagrammen besonders profitieren, die bei der Erläuterung der Charakteristika der Daten hilfreich sein können und Zeit im universitären Alltag sparen. Alle Tabellen und Diagramme liegen auch als separate Dateien vor um sie einfach z.B. in Präsentations-Folien oder Handreichungen zu integrieren.

#'\begin{centering}
#'\begin{longtable}{P{3.5cm}p{10.5cm}}

#'\toprule

#'Variante & Zielgruppe und Beschreibung\\

#'\midrule
#'\endhead

#' CSV\_Einzelnormen\_ Datensatz & \textbf{Legal Tech/Quantitative Forschung}. Diese CSV-Datei ist eine der für statistische Analysen empfohlenen Varianten des Datensatzes. Sie enthält den Volltext aller Rechtsakte, disaggregiert nach Einzelnormen, sowie alle in diesem Codebook beschriebenen Metadaten. Enthält nur Rechtsakte, für die mindestens eine Einzelnorm mit Normtext veröffentlicht wurde!\\
#' CSV\_Einzelnormen\_ Metadaten & \textbf{Legal Tech/Quantitative Forschung}. Wie die andere CSV-Datei mit Einzelnormen, nur ohne die Normtexte. Sinnvoll für Analyst:innen, die sich nur für die Metadaten interessieren und Speicherplatz sparen wollen. Enthält nur Rechtsakte, für die mindestens eine Einzelnorm mit Normtext veröffentlicht wurde!\\
#' CSV\_Rechtsakte\_ Datensatz & \textbf{Legal Tech/Quantitative Forschung}. Diese CSV-Datei ist eine der für statistische Analysen empfohlenen Varianten des Datensatzes. Sie enthält den Volltext aller Rechtsakte, sowie fast alle in diesem Codebook beschriebenen Metadaten. Die gegenüber den Einzelnormen fehlenden Metadaten betreffen vor allem Gliederungsdaten (z.B. Gliederungsüberschrift), die auf Rechtsakts-Ebene keinen Sinn ergeben. Wurde durch ein Zusammenfügen der Einzelnorm-Variante erstellt. Enthält nur Rechtsakte, für die mindestens eine Einzelnorm mit Normtext veröffentlicht wurde!\\
#' CSV\_Rechtsakte\_ Metadaten & \textbf{Legal Tech/Quantitative Forschung}. Wie die andere CSV-Datei mit Rechtsakten, nur ohne die Normtexte. Sinnvoll für Analyst:innen, die sich nur für die Metadaten interessieren und Speicherplatz sparen wollen. Enthält nur Rechtsakte, für die mindestens eine Einzelnorm mit Normtext veröffentlicht wurde!\\
#' CSV\_MetadatenXML & \textbf{Legal Tech/Quantitative Forschung}. Diese CSV-Datei enthält Metadaten für jeden auf der amtlichen Webeite nachgewiesenen Rechtsakt, unabhängig davon, ob mit oder ohne Normtext veröffentlicht. Die Zahl der Rechtsakte ist daher um etwa 1000 höher als bei den anderen CSV-Dateien, es sind aber keine Normtexte enthalten.\\
#' XML\_Datensatz & \textbf{Legal Tech/Quantitative Forschung}. Die XML-Rohdaten. Alle CSV-Dateien wurden aus diesen Rohdaten extrahiert. XML ist ein komplexes Format und daher nur für entsprechend versierte Forscher:innen geeignet.\\
#' XML\_Anlagen & \textbf{Legal Tech/Quantitative Forschung}. Manche XML-Dateien verweisen auf Anlagen, vorwiegend Bild-Dateien. Diese sind hier zusammengefasst.\\
#' PDF\_Datensatz & \textbf{Traditionelle juristische Forschung}. Die PDF-Dokumente wie sie vom Bundesjustizministerium auf der amtlichen Webseite bereitgestellt werden, jedoch verbessert durch semantisch hochwertige Dateinamen, die sowohl die Abkürzung, als auch einen modifizierten Langtitel enthalten. Die Dateinamen sind so konzipiert, dass sie auch für traditionelle qualitative juristische Arbeit einen erheblichen Mehrwert bieten. Im Vergleich zu den CSV-Dateien enthalten die Dateinamen nur einen drastisch reduzierten Umfang an Metadaten, um Kompatibilitätsprobleme unter Windows zu vermeiden und die Lesbarkeit zu verbessern. Besonders geeignet für die Arbeit an Desktop PCs.\\
#' EPUB\_Datensatz & \textbf{Traditionelle juristische Forschung}. Die PDF-Dokumente wie sie vom Bundesjustizministerium auf der amtlichen Webseite bereitgestellt werden, jedoch verbessert durch semantisch hochwertige Dateinamen, die sowohl die Abkürzung, als auch einen modifizierten Langtitel enthalten. Die Dateinamen sind so konzipiert, dass sie auch für traditionelle qualitative juristische Arbeit einen erheblichen Mehrwert bieten. Im Vergleich zu den CSV-Dateien enthalten die Dateinamen nur einen drastisch reduzierten Umfang an Metadaten, um Kompatibilitätsprobleme unter Windows zu vermeiden und die Lesbarkeit zu verbessern. Besonders geeignet für die Arbeit an mobilen Endgeräten, weil sich das Format der Bildschirmgröße anpassen kann.\\
#' TXT\_Datensatz & \textbf{Subsidiär}. Diese Variante enthält die vollständigen aus den PDF-Dateien extrahierten Normtexte der Rechtsakte, aber nur einen drastisch reduzierten Umfang an Metadaten, der dem der PDF-Dateien entspricht. Die TXT-Dateien sind optisch an das Layout der PDF-Dateien angelehnt. Geeignet für qualitative Forscher, die nur wenig Speicherplatz oder eine langsame Internetverbindung zur Verfügung haben und für quantitative Forscher, die beim Einlesen der CSV-Dateien Probleme haben.\\
#' Netzwerke & \textbf{Experimentell}. Die Gliederungshierarchie aller Rechtsakte wurde in eine Netzwerkstruktur übersetzt und ist in verschiedenen Formaten bereitgestellt (GraphML, Adjazenzmatrizen und Edge Lists). Aus dieser Netzwerkstruktur wurden zudem hierarchische Dendrogramme erstellt um einen visuellen Überblick zu bieten. Einzelnormen sind in den Netzwerkstrukturen aktuell noch nicht berücksichtigt. Diese Variante ist noch hoch-experimentell, sollte also nicht ohne genaue Prüfung für die eigene Forschung verwendet werden.\\ 
#' ANALYSE & \textbf{Alle Lehrenden und Forschenden}. Dieses Archiv enthält alle während dem Kompilierungs- und Prüfprozess erstellten Tabellen (CSV) und Diagramme (PDF, PNG) im Original. Sie sind inhaltsgleich mit den in diesem Codebook verwendeten Tabellen und Diagrammen. Das PDF-Format eignet sich besonders für die Verwendung in gedruckten Publikationen, das PNG-Format besonders für die Darstellung im Internet. Analyst:innen mit fortgeschrittenen Kenntnissen in R können auch auf den Source Code zurückgreifen. Empfohlen für Nutzer die einzelne Inhalte aus dem Codebook für andere Zwecke (z.B. eigene Publikationen) weiterverwenden möchten.\\


#'\bottomrule

#'\end{longtable}
#'\end{centering}



#+
#'\newpage



#+
#'# Variablen

#+
#'## Hinweise

#'\begin{itemize}
#'\item Fehlende Werte sind immer mit \enquote{NA} codiert
#'\item Strings können grundsätzlich alle in UTF-8 definierten Zeichen (insbesondere Buchstaben, Zahlen und Sonderzeichen) enthalten.
#'\item Alle Variablen sind in der hier beschriebenen Form nur in der CSV-Datei enthalten. Die meisten davon sind jedoch aus gleichlautenden oder ähnlich lautenden Nodes in den XML-Daten vorhanden. 
#'\end{itemize}

#+
#'## Erläuterungen der einzelnen Variablen

#'\ra{1.3}
#' 
#'\begin{centering}
#'\begin{longtable}{P{3.5cm}P{2.7cm}p{8.3cm}}
#' 
#'\toprule
#' 
#'Variable & Typ & Erläuterung\\
#'
#' 
#'\midrule
#'
#'\endhead
#' 
#' doc\_id & String & Ein einzigartiger Identifikator für jede Einzelnorm bzw. jeden Rechtsakt. Für Rechtsakte entspricht diese Variable dem Namen der extrahierten XML-Datei. Einzelnormen enthalten den Namen der XML-Datei und jeweils eine fortlaufende Zahl. Bei Einzelnormen nicht notwendigerweise stabil zwischen den Versionen des C-DBR. Bei Rechtsakten vermutlich schon.\\
#' dateiname & String & (Nur Einzelnormen-Variante). Der Dateiname der XML-Datei aus dem die Einzelnormen extrahiert wurden.\\
#' text & String & Der vollständige Normtext der Einzelnorm oder des Rechtsaktes, so wie er in den XML-Dateien dokumentiert ist.  Nur die Varianten \enquote{Einzelnormen} und \enquote{Rechtsakte} enthalten Textdaten. Hierzu schreibt das Ministerium in den Hinweisen: \enquote{Einzelne Vorschriften sind nur mit der Überschrift aufgenommen. In einigen Fällen hat dies technische Gründe, in anderen Fällen ist dies dadurch bedingt, dass die Vorschrift nur mit ihren bibliographischen Angaben in der Bereinigten Sammlung Bundesgesetzblatt Teil III enthalten ist (§ 3 Abs. 2 BRSG).}\\
#' amtabk & String & Die amtliche Abkürzung des Rechtsaktes. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' jurabk & String & Unter \enquote{Hinweise} schreibt das Ministerium: \enquote{Zu einigen Gesetzen und Verordnungen existieren keine amtlichen Abkürzungen. In diesen Fällen sind die Vorschriften in den alphabetischen Listen von \enquote{Gesetze im Internet} anhand der von der Dokumentationsstelle im BfJ gebildeten und in der Bundesrechtsdatenbank verwendeten Abkürzungen eingeordnet. Diese nichtamtlichen Abkürzungen können von Abkürzungen, die andere Anbieter verwenden, abweichen.} Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' langue & String & Die Langform des Namens (Langüberschrift) eines Rechtsaktes. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' kurzue & String & Die Kurzform des Namens (Kurzüberschrift) eines Rechtsaktes. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' gliederungskennzahl & String & (Nur Einzelnormen-Variante). Die Kennzahl der jeweiligen Gliederungsebene. Das zugrundeliegende System ist vom Ministerium nicht dokumentiert. Beispielsweise \enquote{010050030}. Vermutlich ist jede Gliederungsebene mit drei Zahlen definiert: die ersten beiden Zahlen bilden die Ordinalzahl innerhalb der Ebene (ggf. mit vorangestellter Null falls kleiner 10), die dritte Zahl ist meistens eine Null und wird ggf. erhöht falls die Gliederungsbezeichnung mit Buchstaben ausdifferenziert wurde (nachträgliche Einfügung). Das Beispiel enthält also drei Ebenen: erste Überschrift der 1. Ebene, fünfte Überschrift der 2. Ebene, dritte Überschrift der 3. Ebene.\\
#' gliederungsbez & String & (Nur Einzelnormen-Variante). Die Bezeichnung der Gliederungsebene. Beispielsweise \enquote{Titel 3}.\\
#' gliederungstitel & String & (Nur Einzelnormen-Variante). Der Titel der Gliederungsebene. Beispielsweise \enquote{Rechtsfolgen der Verjährung}.\\
#' enbez & String & (Nur Einzelnormen-Variante). Die Bezeichnung der Einzelnorm. Beispielsweise \enquote{§ 214}.\\
#' bezkette & String & Die volle Hierarchie der Bezeichnungen der Gliederungsebenen in Form einer Kette. Beispiel: \enquote{Buch 2 | Abschnitt 8 | Titel 5 | Untertitel 2 | Kapitel 5 | Unterkapitel 4}.\\
#' titelkette & String & Die volle Hierarchie der Titel der Gliederungsebenen in Form einer Kette. Beispiel: \enquote{Recht der Schuldverhältnisse | Einzelne Schuldverhältnisse | Mietvertrag, Pachtvertrag | Mietverhältnisse über Wohnraum | Beendigung des Mietverhältnisses | Werkwohnungen}.\\
#' ausfertigung\_datum & Datum (ISO) & Das Datum an dem der Rechtsakt ausgefertigt wurde. Das Format ist YYYY-MM-DD (Langform nach ISO-8601). Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt! Daher sind beispielsweise für das BGB alle Normen mit dem Ausfertigungsjahr 1896 versehen, auch wenn die Einzelnorm später erlassen wurde.\\
#' ausfertigung\_jahr & Natürliche Zahl & Das Jahr in dem der Rechtsakt ausgefertigt wurde. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt. Das Format ist eine vierstellige Jahreszahl (YYYY). Wurde durch den Autor aus dem Ausfertigungsdatum berechnet.\\
#' aenderung\_datum & Datum (ISO) & Das Datum der letzten Änderung des Rechtsakts.  Das Format ist YYYY-MM-DD (Langform nach ISO-8601).  Aus der Variable \enquote{stand} mittels \emph{regular expressions} extrahiert.\\
#' aufhebung\_ \mbox{verkuendung\_datum} & Datum (ISO) & Das Datum an dem ein etwaiger aufhebender Rechtsakt verkündet wurde.  Das Format ist YYYY-MM-DD (Langform nach ISO-8601). Aus der Variable \enquote{aufh} mittels \emph{regular expressions} extrahiert.\\
#' aufhebung\_ wirkung\_datum & Datum (ISO) & Das Datum an dem ein etwaiger aufhebender Rechtsakt wirksam wird.   Das Format ist YYYY-MM-DD (Langform nach ISO-8601). Aus der Variable \enquote{aufh} mittels \emph{regular expressions} extrahiert.\\
#' neufassung\_datum & String & Das Datum an dem der Rechtsakt zuletzt neugefasst wurde. Das Format ist YYYY-MM-DD (Langform nach ISO-8601). Aus der Variable \enquote{neuf} mittels \emph{regular expressions} extrahiert.\\
#' builddate\_original & String & Datum und Uhrzeit an dem die XML-Repräsentation der Norm konstruiert wurde, eine Serie von Zahlen ohne Interpunktion. Das genaue Format ist nicht dokumentiert, es ist aber sehr wahrscheinlich so aufgebaut: vierstellige Jareszahl, zweistellige Monatszahl, zweistellige Tageszahl, zweistellige Stundenzahl, zweistellige Minutenzahl und eine zweistellige Sekundenzahl.\\
#' builddate\_iso & Zeitstempel (ISO) & Eine Interpretation der builddate-Variable im ISO 8601-Format (z.B. 2016-09-12T18:12:16Z). Das genaue Original-Format ist nicht dokumentiert, die Variable wurde aber unter folgenden Annahmen extrahiert: vierstellige Jareszahl, zweistellige Monatszahl, zweistellige Tageszahl, zweistellige Stundenzahl, zweistellige Minutenzahl und eine zweistellige Sekundenzahl.\\
#' fundstellentyp & String & Ob es sich um eine amtliche Fundstelle handelt oder nicht. Mögliche Werte sind \enquote{amtlich} oder \enquote{nichtamtlich}. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' periodikum & String & Die Abkürzung des Periodikums in dem die amtliche Fassung des Rechtsaktes erschienen ist, beispielsweise \enquote{BGBl I} (Bundesgesetzblatt I). Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' zitstelle & String & Die genaue Fundstelle im jeweiligen Periodikum. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' stand & String & Informationen zum aktuellen Stand des Rechtsaktes, als Fließtext. Enthält insbesondere Informationen zur letzten Änderung und dem letzten Änderungsrechtsakt. Jeweils durch einen vertikalen Strich \enquote{|} getrennt, falls mehr als eine Bemerkung vorhanden ist. Falls nicht vorhanden ist der Wert \enquote{NA}. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' aufh & String & Informationen zur etwaigen Aufhebung des Rechtsaktes, als Fließtext. Jeweils durch einen vertikalen Strich \enquote{|} getrennt, falls mehr als eine Bemerkung vorhanden ist. Falls nicht vorhanden ist der Wert \enquote{NA}. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' neuf & String & Informationen zur letzten Neufassung des Rechtsaktes, als Fließtext. Jeweils durch einen vertikalen Strich \enquote{|} getrennt, falls mehr als eine Bemerkung vorhanden ist. Falls nicht vorhanden ist der Wert \enquote{NA}. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' hinweis & String & Hinweise zur dokumentarischen Bearbeitung des Rechtsaktes, als Fließtext. Jeweils durch einen vertikalen Strich \enquote{|} getrennt, falls mehr als eine Bemerkung vorhanden ist. Falls nicht vorhanden ist der Wert \enquote{NA}. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' sonst & String & Sonstige Informationen zum Stand des Rechtsaktes, als Fließtext. Jeweils durch einen vertikalen Strich \enquote{|} getrennt, falls mehr als eine Bemerkung vorhanden ist. Falls nicht vorhanden ist der Wert \enquote{NA}. Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt!\\
#' check\_* & String & Ob die Angabe der jeweiligen Stand-Variable geprüft wurde. Es ist unklar, welche Prüfung hier vom Ministerium vorgenommen wurde. Mögliche Werte sind \enquote{ja} oder \enquote{NA}.  Für Einzelnormen bezieht sich die Angabe auf den gesamten Rechtsakt! \\
#' tokens & Natürliche Zahl & (Nur CSV-Datei) Die Anzahl Tokens (beliebige Zeichenfolge getrennt durch whitespace) eines Dokumentes. Diese Zahl kann je nach Tokenizer und verwendeten Einstellungen erheblich schwanken. Für diese Berechnung wurde eine reine Tokenisierung ohne Entfernung von Inhalten durchgeführt. Benutzen Sie diesen Wert eher als Anhaltspunkt für die Größenordnung denn als exakte Aussage und führen sie ggf. mit ihrer eigenen Software eine Kontroll-Rechnung durch.\\
#' typen & Natürliche Zahl & Die Anzahl einzigartiger Tokens (beliebige Zeichenfolge getrennt durch whitespace) eines Dokumentes. Diese Zahl kann je nach Tokenizer und verwendeten Einstellungen erheblich schwanken. Für diese Berechnung wurde eine reine Tokenisierung und Typenzählung ohne Entfernung von Inhalten durchgeführt. Benutzen Sie diesen Wert eher als Anhaltspunkt für die Größenordnung denn als exakte Aussage und führen sie ggf. mit ihrer eigenen Software eine Kontroll-Rechnung durch.\\
#' saetze & Natürliche Zahl & Die Anzahl Sätze. Entsprechen in etwa dem üblichen Verständnis eines Satzes. Die Regeln für die Bestimmung von Satzanfang und Satzende sind im Detail sehr komplex und in \enquote{Unicode Standard Annex No 29} beschrieben. Diese Zahl kann je nach Software und verwendeten Einstellungen erheblich schwanken. Für diese Berechnung wurde eine reine Zählung ohne Entfernung von Inhalten durchgeführt. Benutzen Sie diesen Wert eher als Anhaltspunkt für die Größenordnung denn als exakte Aussage und führen sie ggf. mit ihrer eigenen Software eine Kontroll-Rechnung durch.\\
#' version & Datum & Die Versionsnummer des Datensatzes im Format YYYY-MM-DD (Langform nach ISO-8601). Die Versionsnummer entspricht immer dem Datum an dem der Datensatz erstellt und die Daten von der Webseite des Gerichts abgerufen wurden.\\
#' doi\_concept & String & Der Digital Object Identifier (DOI) des Gesamtkonzeptes des Datensatzes. Dieser ist langzeit-stabil (persistent). Über diese DOI kann via www.doi.org immer die \textbf{aktuellste Version} des Datensatzes abgerufen werden. Prinzip F1 der FAIR-Data Prinzipien (\enquote{data are assigned globally unique and persistent identifiers}) empfiehlt die Dokumentation jeder Messung mit einem persistenten Identifikator. Selbst wenn die CSV-Dateien ohne Kontext weitergegeben werden kann ihre Herkunft so immer zweifelsfrei und maschinenlesbar bestimmt werden.\\
#' doi\_version & String &  Der Digital Object Identifier (DOI) der \textbf{konkreten Version} des Datensatzes. Dieser ist langzeit-stabil (persistent). Über diese DOI kann via www.doi.org immer diese konkrete Version des Datensatzes abgerufen werden. Prinzip F1 der FAIR-Data Prinzipien (\enquote{data are assigned globally unique and persistent identifiers}) empfiehlt die Dokumentation jeder Messung mit einem persistenten Identifikator. Selbst wenn die CSV-Dateien ohne Kontext weitergegeben werden kann ihre Herkunft so immer zweifelsfrei und maschinenlesbar bestimmt werden.\\
#' lizenz & String & Die Lizenz des Datensatzes. In diesem Fall immer \enquote{Creative Commons Zero 1.0 Universal}.\\
#' 
#'\bottomrule
#' 
#'\end{longtable}
#'\end{centering}




#'\newpage
#'## Konkordanztabelle: XML-Struktur und CSV-Variablen


#'\begin{longtable}{lll}

#'\toprule

#' CSV-Variable & XPath & Attribut\\

#'\midrule

#' text & /norm/textdaten/text/Content & -\\
#' builddate\_original & /norm & builddate\\
#' fundstellentyp & /norm/metadaten/fundstelle & typ\\
#' periodikum & /norm/metadaten/fundstelle/periodikum & -\\
#' zitstelle & /norm/metadaten/fundstelle/zitstelle & -\\
#' stand & /norm/metadaten/standangabe/standtyp & -\\
#'      & /norm/metadaten/standangabe/standkommentar & -\\
#' aufh & /norm/metadaten/standangabe/standtyp & -\\
#'      & /norm/metadaten/standangabe/standkommentar & -\\
#' neuf & /norm/metadaten/standangabe/standtyp & -\\
#'      & /norm/metadaten/standangabe/standkommentar & -\\
#' hinweis & /norm/metadaten/standangabe/standtyp & -\\
#'       & /norm/metadaten/standangabe/standkommentar & -\\
#' sonst & /norm/metadaten/standangabe/standtyp & -\\
#'       & /norm/metadaten/standangabe/standkommentar & -\\
#' check\_* & /norm/metadaten/standangabe & checked\\
#' amtabk & /norm/metadaten/amtabk & - \\
#' jurabk & /norm/metadaten/jurabk & - \\
#' langue & /norm/metadaten/langue & - \\
#' kurzue & /norm/metadaten/kurzue & - \\
#' gliederungskennzahl & /norm/metadaten/gliederungseinheit/gliederungskennzahl & - \\
#' gliederungsbez & /norm/metadaten/gliederungseinheit/gliederungsbez & - \\
#' gliederungstitel & /norm/metadaten/gliederungseinheit/gliederungstitel & - \\
#' enbez & /norm/metadaten/enbez & - \\
#' ausfertigung\_datum & /norm/metadaten/ausfertigung-datum & - \\
#'\bottomrule

#'\end{longtable}



#'\newpage
#+
#'# Linguistische Kennzahlen


#+
#'## Erläuterung der Kennzahlen

#' Zur besseren Einschätzung des inhaltlichen Umfangs des Korpus dokumentiere ich an dieser Stelle die Verteilung der Werte für drei verschiedene klassische linguistische Kennzahlen:

#' \medskip

#'\begin{centering}
#'\begin{longtable}{P{3.5cm}p{10.5cm}}

#'\toprule

#'Variable & Definition\\

#'\midrule

#' Zeichen & Zeichen entsprechen grob den \emph{Graphemen}, den kleinsten funktionalen Einheiten in einem Schriftsystem. Beispiel: das Wort \enquote{Richterin} besteht aus 9 Zeichen.\\
#' Tokens & Eine beliebige Zeichenfolge, getrennt durch whitespace-Zeichen, d.h. ein Token entspricht in der Regel einem \enquote{Wort}, kann aber gelegentlich auch sinnlose Zeichenfolgen enthalten, weil es rein syntaktisch berechnet wird.\\
#' Typen & Einzigartige Tokens. Beispiel: wenn das Token \enquote{gewerblich} mehrmals in einer Norm vorhanden ist, wird es als ein Typ gezählt.\\
#' Sätze & Entsprechen in etwa dem üblichen Verständnis eines Satzes. Die Regeln für die Bestimmung von Satzanfang und Satzende sind im Detail aber sehr komplex und in \enquote{Unicode Standard: Annex No 29} beschrieben. Für Rechtsnormen ist diese Zählweise vermutlich nicht robust genug, interpretieren Sie die Ergebnisse mit großer Vorsicht!\\

#'\bottomrule

#'\end{longtable}
#'\end{centering}
#'



#+
#'## Kennzahlen: Einzelnormen

setnames(stats.normen.ling, c("Kennzahl",
                              "Gesamt",
                              "Min",
                              "1. Quartil",
                              "Median",
                              "Mittel",
                              "3. Quartil",
                              "Max"))

stats.normen.ling$Kennzahl <- c("Zeichen",
                                "Tokens",
                                "Typen",
                                "Sätze")

kable(stats.normen.ling,
      digits = 2,
      format.args = list(big.mark = ","),
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)


#+
#'## Kennzahlen: Rechtsakte

setnames(stats.rechtsakte.ling, c("Kennzahl",
                                  "Gesamt",
                                  "Min",
                                  "1. Quartil",
                                  "Median",
                                  "Mittel",
                                  "3. Quartil",
                                  "Max"))

stats.rechtsakte.ling$Kennzahl <- c("Zeichen",
                                    "Tokens",
                                    "Typen",
                                    "Sätze")

kable(stats.rechtsakte.ling,
      digits = 2,
      format.args = list(big.mark = ","),
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)




#'\newpage

#+
#'## Verteilung Zeichen


#' ![](analyse/C-DBR_04_Einzelnormen_Density_Zeichen-1.pdf)

#'\bigskip

#' ![](analyse/C-DBR_04_Rechtsakte_Density_Zeichen-1.pdf)



#+
#'## Verteilung Tokens


#' ![](analyse/C-DBR_05_Einzelnormen_Density_Tokens-1.pdf)

#'\bigskip

#' ![](analyse/C-DBR_05_Rechtsakte_Density_Tokens-1.pdf)




#+
#'## Verteilung Typen


#' ![](analyse/C-DBR_06_Einzelnormen_Density_Typen-1.pdf)

#'\bigskip

#' ![](analyse/C-DBR_06_Rechtsakte_Density_Typen-1.pdf)



#+
#'## Verteilung Sätze


#' ![](analyse/C-DBR_07_Einzelnormen_Density_Saetze-1.pdf)

#'\bigskip

#' ![](analyse/C-DBR_07_Rechtsakte_Density_Saetze-1.pdf)





    
#' \newpage
#' \ra{1.4}
#+
#'# Inhalt

#+
#'## Nach Periodikum

#+
#'### Einzelnormen


#' ![](analyse/C-DBR_02_Einzelnormen_Barplot_Periodikum-1.pdf)


freqtable <- table.normen.periodikum[-.N]

kable(freqtable[,c(1:2,4:5)],
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Periodikum",
                    "Einzelnormen",
                    "% Gesamt",
                    "% Kumulativ")) %>% kable_styling(latex_options = "repeat_header")




#'\newpage
#+
#'### Rechtsakte mit veröffentlichtem Normtext



#' ![](analyse/C-DBR_02_Rechtsakte_Barplot_Periodikum-1.pdf)


freqtable <- table.rechtsakte.periodikum[-.N]

#'\newpage

kable(freqtable[,c(1:2,4:5)],
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Periodikum",
                    "Rechtsakte",
                    "% Gesamt",
                    "% Kumulativ")) %>% kable_styling(latex_options = "repeat_header")




#'\newpage
#+
#'### Alle Rechtsakte (mit und ohne Normtext)


#' ![](analyse/C-DBR_02_Meta_Barplot_Periodikum-1.pdf)


#'\newpage

freqtable <- table.meta.periodikum[-.N]

kable(freqtable[,c(1:2,4:5)],
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Periodikum",
                    "Rechtsakte",
                    "% Gesamt",
                    "% Kumulativ")) %>% kable_styling(latex_options = "repeat_header")



#'\newpage

#'## Nach Ausfertigungsjahr


#+
#'### Einzelnormen

freqtable <- table.normen.ausjahr[-.N][,lapply(.SD, as.numeric)]


#' ![](analyse/C-DBR_03_Einzelnormen_Barplot_Ausfertigungsjahr-1.pdf)




kable(freqtable[,c(1:2,4:5)],
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Jahr",
                    "Einzelnormen",
                    "% Gesamt",
                    "% Kumulativ")) %>% kable_styling(latex_options = "repeat_header")




#'\newpage
#+
#'### Rechtsakte mit veröffentlichtem Normtext


#' ![](analyse/C-DBR_03_Rechtsakte_Barplot_Ausfertigungsjahr-1.pdf)



freqtable <- table.rechtsakte.ausjahr[-.N][,lapply(.SD, as.numeric)]

kable(freqtable[,c(1:2,4:5)],
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Jahr",
                    "Rechtsakte",
                    "% Gesamt",
                    "% Kumulativ")) %>% kable_styling(latex_options = "repeat_header")


#'\newpage
#+
#'###  Alle Rechtsakte (mit und ohne Normtext)



#' ![](analyse/C-DBR_03_Meta_Barplot_Ausfertigungsjahr-1.pdf)



freqtable <- table.meta.ausjahr[-.N][,lapply(.SD, as.numeric)]

kable(freqtable[,c(1:2,4:5)],
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Jahr",
                    "Rechtsakte",
                    "% Gesamt",
                    "% Kumulativ")) %>% kable_styling(latex_options = "repeat_header")




#+
#'# Dateigrößen: Summen und Verteilungen


files.zip <- fread(hashfile)$filename
files.zip <- file.path("output", files.zip)
filesize <- round(file.size(files.zip) / 10^6, digits = 2)

table.size <- data.table(basename(files.zip),
                         filesize)


kable(table.size,
      format = "latex",
      align = c("l", "r"),
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Datei",
                    "Größe in MB"))


#' ![](analyse/C-DBR_08_Density_Dateigroessen_PDF-1.pdf)

#'\vspace{1cm}

#' ![](analyse/C-DBR_09_Density_Dateigroessen_EPUB-1.pdf)

#' ![](analyse/C-DBR_10_Density_Dateigroessen_XML-1.pdf)

#'\vspace{1cm}

#' ![](analyse/C-DBR_11_Density_Dateigroessen_TXT-1.pdf)





#'\newpage
#+
#'# Signaturprüfung

#+
#'## Allgemeines
#' Die Integrität und Echtheit der einzelnen Archive des Datensatzes sind durch eine Zwei-Phasen-Signatur sichergestellt.
#'
#' In **Phase I** werden während der Kompilierung für jedes ZIP-Archiv Hash-Werte in zwei verschiedenen Verfahren berechnet und in einer CSV-Datei dokumentiert.
#'
#' In **Phase II** wird diese CSV-Datei mit meinem persönlichen geheimen GPG-Schlüssel signiert. Dieses Verfahren stellt sicher, dass die Kompilierung von jedermann durchgeführt werden kann, insbesondere im Rahmen von Replikationen, die persönliche Gewähr für Ergebnisse aber dennoch vorhanden ist.
#'
#' Dieses Codebook ist vollautomatisch erstellt und prüft die kryptographisch sicheren SHA3-512 Signaturen (\enquote{hashes}) aller ZIP-Archive, sowie die GPG-Signatur der CSV-Datei, welche die SHA3-512 Signaturen enthält. SHA3-512 Signaturen werden durch einen system call zur OpenSSL library auf Linux-Systemen berechnet. Eine erfolgreiche Prüfung meldet \enquote{Signatur verifiziert!}. Eine gescheiterte Prüfung meldet \enquote{FEHLER!}

#+
#'## Persönliche GPG-Signatur
#' Die während der Kompilierung des Datensatzes erstellte CSV-Datei mit den Hash-Prüfsummen ist mit meiner persönlichen GPG-Signatur versehen. Der mit dieser Version korrespondierende Public Key ist sowohl mit dem Datensatz als auch mit dem Source Code hinterlegt. Er hat folgende Kenndaten:
#' 
#' **Name:** Sean Fobbe (fobbe-data@posteo.de)
#' 
#' **Fingerabdruck:** FE6F B888 F0E5 656C 1D25  3B9A 50C4 1384 F44A 4E42

#+
#'## Import: Public Key
#+ echo = TRUE
system2("gpg2", "--import gpg/PublicKey_Fobbe-Data.asc",
        stdout = TRUE,
        stderr = TRUE)




#'\newpage
#+
#'## Prüfung: GPG-Signatur der Hash-Datei

#+ echo = TRUE

# CSV-Datei mit Hashes
print(hashfile)

# GPG-Signatur
print(signaturefile)

# GPG-Signatur prüfen
testresult <- system2("gpg2",
                      paste("--verify", signaturefile, hashfile),
                      stdout = TRUE,
                      stderr = TRUE)

# Anführungsstriche entfernen um Anzeigefehler zu vermeiden
testresult <- gsub('"', '', testresult)

#+ echo = TRUE
kable(testresult, format = "latex", booktabs = TRUE,
      longtable = TRUE, col.names = c("Ergebnis"))


#'\newpage
#+
#'## Prüfung: SHA3-512 Hashes der ZIP-Archive
#+ echo = TRUE

# Prüf-Funktion definieren
sha3test <- function(filename, sig){
    sig.new <- system2("openssl",
                       paste("sha3-512", filename),
                       stdout = TRUE)
    sig.new <- gsub("^.*\\= ", "", sig.new)
    if (sig == sig.new){
        return("Signatur verifiziert!")
    }else{
        return("FEHLER!")
    }
}

# Ursprüngliche Signaturen importieren
table.hashes <- fread(hashfile)
filename <- file.path("output", table.hashes$filename)
sha3.512 <- table.hashes$sha3.512

# Signaturprüfung durchführen 
sha3.512.result <- mcmapply(sha3test, filename, sha3.512, USE.NAMES = FALSE)

# Ergebnis anzeigen
testresult <- data.table(basename(filename), sha3.512.result)

#+ echo = TRUE
kable(testresult, format = "latex", booktabs = TRUE,
      longtable = TRUE, col.names = c("Datei", "Ergebnis"))




#+
#'# Changelog
#'
#'
#'## Version \version
#'
#'- Vollständige Aktualisierung der Daten
#'- Strenge Versionskontrolle aller R packages
#'- Der Prozess der Kompilierung ist jetzt detailliert konfigurierbar, insbesondere die Parallelisierung
#'- Parallelisierung der XML-Parser deaktivert, weil instabil
#'- Fehlerhafte Kompilierungen werden nun beim nächsten Run vollautomatisch aufgeräumt
#'- Alle Ergebnisse werden automatisch fertig verpackt in den Ordner \enquote{output} sortiert
#'- Source Code des Changelogs zu Markdown konvertiert
#'- Einführung eines Debugging-Modus um die Entwicklung zu beschleunigen
#'
#'## Version 2021-09-16
#'
#'- Vollständige Aktualisierung der Daten
#'- Einfügung von Kurzbezeichnungen der Rechtsakte in die Dateinamen der Netzwerkanalysen
#'- Einfügung der ID der Rechtsakte in die CSV-Tabelle aller Kurz- und Langtitel
#'
#' 
#'## Version 2021-07-30
#' 
#'- Vollständige Aktualisierung der Daten
#'- Einführung von neuen Variablen für letzte Änderung (Datum), Neufassung (Datum), Aufhebung (Datum jeweils für Verkündung und Wirkung), Lizenz und hierarchische Ketten von Gliederungsbezeichnungen und -titeln
#'- Parallelisierung der Downloads um Kompilierung des Korpus zu beschleunigen
#'- Korrektur bei den Dateinamen der Allgemeinen Eisenbahngesetze: GII weist zwei gleichnamige Rechtsakte (\enquote{Allgemeines Eisenbahngesetz}) nach. Beide werden nun mit dem Jahr ihrer Ausfertigung 1951 und 1993 im Langtitel differenziert. In der Vorversion wurde das neuere AEG noch mit dem Jahr 1994 (Inkrafttreten) beschriftet und das andere AEG ohne Jahreszahl.
#'- Einführung von Netzwerkanalysen (experimentell!)
#'- Variablen in CSV-Dateien sind nun semantisch sortiert
#'- Neues Diagramm für Verteilung von Zeichen
#'- Falls die XML-Datei mehrere Bemerkungen für Hinweise, Änderung, Neufassung, den Stand oder sonstige Angaben aufweist werden diese nun durch einen vertikalen Strich getrennt (vorher nur mehrere Leerzeichen). 
#'- Kleinere Korrekturen und Ergänzungen im Codebook
#'
#' 
#'## Version 2021-01-05
#'
#' 
#'- Vollständige Aktualisierung der Daten
#'- Komplette Überarbeitung des Source Codes
#'- Erstveröffentlichung eines Codebooks
#'- Einführung der vollautomatischen Erstellung von Datensatz und Codebook
#'- Einführung von Compilation Reports um den Erstellungsprozess exakt zu dokumentieren
#'- CSV-Dateien werden durch Parsing der XML-Dateien erstellt
#'- Automatisierung und deutliche Erweiterung der Qualitätskontrolle
#'- Einführung von Diagrammen zur Visualisierung von Prüfergebnissen
#'- Einführung kryptographischer Signaturen
#' 
#' 
#'## Version 2020-10-09
#'
#'
#'- Vollständige Aktualisierung der Daten
#'- Erstveröffentlichung des Source Codes
#'- XML-Daten nun fehlerfrei. In Version 2020-07-08 waren XML-Dateien mit Anhängen fehlerhaft.
#'
#' 
#' 
#'## Version 2020-07-08
#'
#' 
#'- Vollständige Aktualisierung der Daten
#' 
#' 
#'## Version 2020-05-18
#'
#'- Erstveröffentlichung
#' 

#'\newpage
#+
#'# Parameter für strenge Replikationen

system2("openssl",  "version", stdout = TRUE)

sessionInfo()

#'# Literaturverzeichnis

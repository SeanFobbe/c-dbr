[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.3832111.svg)](https://doi.org/10.5281/zenodo.3832111)

# Corpus des Deutschen Bundesrechts
Das **Corpus des deutschen Bundesrechts (C-DBR)** ist eine möglichst vollständige Sammlung der konsolidierten Fassungen aller Gesetze und Verordnungen auf Bundesebene. Der Datensatz nutzt als seine Datenquelle das amtliche Internetangebot www.gesetze-im-internet.de des Bundesministeriums der Justiz und wertet dieses vollständig aus.

Alle mit diesem Skript erstellten Datensätze werden dauerhaft kostenlos und urheberrechtsfrei auf Zenodo, dem wissenschaftlichen Archiv des CERN, veröffentlicht. Alle Versionen sind mit einem separaten und langzeit-stabilen (persistenten) Digital Object Identifier (DOI) versehen.

Aktuellster, funktionaler und zitierfähiger Release des Datensatzes: https://doi.org/10.5281/zenodo.3832111

Aktuellster, funktionaler und zitierfähiger Release des Source Codes: https://doi.org/10.5281/zenodo.4072934

Lesen Sie bitte zuerst den *Compilation Report* auf Zenodo (via Source Code link)! Dieser enthält den gesamten R Source Code, relevante Rechenergebnisse, alle Diagramme, Zeitstempel, sowie ein detailliertes und klickbares Inhaltsverzeichnis. Sie werden sich auf diese Weise viel schneller im eigentlichen Source Code zurechtfinden.


 

# Funktionsweise

Primäre Endprodukte des Skripts sind folgende ZIP-Archive:

1. Der volle Datensatz im CSV-Format, unterteilt in Einzelnormen; nur Rechtsakte mit veröffentlichtem Normtext sind erfasst
2. Die Metadaten aller Einzelnormen im CSV-Format (wie 1, nur ohne Normtexte)
3. Der volle Datensatz im CSV-Format, unterteilt in Rechtsakte; nur Rechtsakte mit veröffentlichtem Normtext sind erfasst
4. Die Metadaten aller Rechtsakte im CSV-Format (wie 3, nur ohne Normtexte)
5. Die Metadaten aller auf »Gesetze im Internet« als XML veröffentlichten Rechtsakte, im CSV-Format, unabhängig davon ob sie Normtext enthalten oder nicht
6. Der volle Datensatz im XML-Format, unterteilt in Rechtsakte; Grundlage für die CSV-Varianten
7. Alle Anlagen zu den XML-Dateien im jeweiligen Original-Format
8. Alle Rechtstexte im TXT-Format, unterteilt in Rechtsakte (deutlich reduzierter Umfang an Metadaten)
9. Alle Rechtstexte im PDF-Format, unterteilt in Rechtsakte (deutlich reduzierter Umfang an Metadaten)
10. Alle Rechtstexte im EPUB-Format, unterteilt in Gesetze (deutlich reduzierter Umfang an Metadaten)
11. Alle Analyse-Ergebnisse (Tabellen als CSV, Grafiken als PDF und PNG)
12. Netzwerk-Strukturen (Adjazenzmatrizen, Edgelists, GraphML, und Netzwerk-Diagramme) für alle Rechtsakte (experimentell!)

Zusätzlich werden für alle ZIP-Archive kryptographische Signaturen (SHA2-256 und SHA3-512) berechnet und in einer CSV-Datei hinterlegt. Die Analyse-Ergebnisse werden zum Ende hin nicht gelöscht, damit sie für die Codebook-Erstellung verwendet werden können.

Weiterhin kann optional ein PDF-Bericht erstellt werden (siehe unter »Kompilierung«).

 

# Systemanforderungen

Der Code in seiner veröffentlichten Form kann nur unter Linux ausgeführt werden, da er Linux-spezifische Optimierungen (z.B. Fork Cluster) und Shell-Kommandos (z.B. OpenSSL) nutzt. Der Code wurde unter Fedora Linux entwickelt und getestet. Die zur Kompilierung benutzte Version entnehmen Sie bitte dem sessionInfo()-Ausdruck am Ende des Compilation Reports im Zenodo-Archiv.

In der Standard-Einstellung wird das Skript vollautomatisch die maximale Anzahl an Rechenkernen/Threads auf dem System zu nutzen. Die Parallelisierung kann in der Konfigurations-Datei detailliert konfiguriert werden.

Auf der Festplatte sollten 8 GB Speicherplatz vorhanden sein.

Um die PDF-Berichte kompilieren zu können benötigen Sie das R package rmarkdown, eine vollständige Installation von LaTeX und alle in der Präambel-TEX-Datei angegebenen LaTeX Packages.

 

# Kompilierung: Vorbemerkungen

Dem Source Code ist ein 'lockfile' für das R package [renv](https://rstudio.github.io/renv/articles/renv.html) beigelegt, mit dem optional die verwendeten Versionen aller R packages streng kontrolliert und einfach wiederhergestellt werden können. renv installiert die packages in einen separaten Ordner innerhalb des Projektes und kann gefahrfrei parallel mit Ihrer eigenen R library verwendet werden. Wenn Sie die Kompilierung mit den ursprünglich verwendeten Versionen durchführen wollen, führen Sie bitte im Ordner mit dem Source Code innerhalb von R folgende Befehle aus:

``` 
renv::activate() # Aktiviert renv

renv::restore() # Installiert die im Lockfile angegebenen Package-Versionen
```
 

# Kompilierung: Datensatz und Codebook

Mit der Funktion render() von rmarkdown können der vollständige Datensatz und das Codebook kompiliert und die Skripte mitsamt ihrer Rechenergebnisse in ein gut lesbares PDF-Format überführt werden.

Alle Kommentare sind im roxygen2-Stil gehalten. Die beiden Skripte können daher auch ohne render() regulär als R-Skripte ausgeführt werden. Es wird in diesem Fall kein PDF-Bericht erstellt und Diagramme werden nicht abgespeichert.

Um den vollständigen Datensatz und das Codebook zu kompilieren und einen PDF-Bericht zu erstellen, kopieren Sie bitte alle im Source-Archiv bereitgestellten Dateien in einen leeren Ordner und führen mit R diesen Befehl aus:

```
source("00_C-DBR_FullCompile.R")
```

Bei der Prüfung der GPG-Signatur im Codebook wird ein Fehler auftreten und im Codebook dokumentiert, weil die Daten nicht mit meiner Original-Signatur versehen sind. Dieser Fehler hat jedoch keine Auswirkungen auf die Funktionalität und hindert die Kompilierung nicht.

 

# Weitere Open Access Veröffentlichungen (Fobbe)

Website — https://www.seanfobbe.de

Open Data  —  https://zenodo.org/communities/sean-fobbe-data/

Source Code  —  https://zenodo.org/communities/sean-fobbe-code/

Volltexte regulärer Publikationen  —  https://zenodo.org/communities/sean-fobbe-publications/



# Kontakt

Fehler gefunden? Anregungen? Kommentieren Sie gerne im Issue Tracker auf GitHub oder schreiben Sie mir eine E-Mail an [fobbe-data@posteo.de](fobbe-data@posteo.de)

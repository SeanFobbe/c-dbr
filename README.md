[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.3832111.svg)](https://doi.org/10.5281/zenodo.3832111)

# README: Corpus des Deutschen Bundesrechts (C-DBR)


## Überblick

Das **Corpus des deutschen Bundesrechts (C-DBR)** ist eine möglichst vollständige Sammlung der konsolidierten Fassungen aller Gesetze und Verordnungen auf Bundesebene. Der Datensatz nutzt als seine Datenquelle das amtliche Internetangebot www.gesetze-im-internet.de des Bundesministeriums der Justiz und wertet dieses vollständig aus.

Alle mit diesem Skript erstellten Datensätze werden dauerhaft kostenlos und urheberrechtsfrei auf Zenodo, dem wissenschaftlichen Archiv des CERN, veröffentlicht. Alle Versionen sind mit einem separaten und langzeit-stabilen (persistenten) Digital Object Identifier (DOI) versehen.

Aktuellster, funktionaler und zitierfähiger Release des Datensatzes: https://doi.org/10.5281/zenodo.3832111

Aktuellster, funktionaler und zitierfähiger Release des Source Codes: https://doi.org/10.5281/zenodo.4072934



## Funktionsweise

Primäre Endprodukte des Skripts sind folgende ZIP-Archive:

1. Der volle Datensatz im CSV-Format, unterteilt in Einzelnormen (nur Rechtsakte mit veröffentlichtem Normtext)
2. Die Metadaten aller Einzelnormen im CSV-Format (wie 1, aber ohne Text-Variable)
3. Der volle Datensatz im CSV-Format, unterteilt in Rechtsakte (nur Rechtsakte mit veröffentlichtem Normtext)
4. Die Metadaten aller Rechtsakte im CSV-Format (wie 3, aber ohne Text-Variable)
5. Die Metadaten aller veröffentlichten Rechtsakte, im CSV-Format (unabhängig davon ob Normtext veröffentlicht wurde)
6. Der volle Datensatz im XML-Format, unterteilt in Rechtsakte (Originaldaten von GII)
7. Alle Anlagen zu den XML-Dateien im jeweiligen Original-Format (Originaldaten von GII)
8. Alle Rechtsakte im TXT-Format, unterteilt in Rechtsakte (deutlich reduzierter Umfang an Metadaten)
9. Alle Rechtstexte im PDF-Format, unterteilt in Rechtsakte (deutlich reduzierter Umfang an Metadaten)
10. Alle Rechtstexte im EPUB-Format, unterteilt in Gesetze (deutlich reduzierter Umfang an Metadaten)
11. Alle Analyse-Ergebnisse (Tabellen als CSV, Grafiken als PDF und PNG)
12. Netzwerk-Strukturen (Adjazenzmatrizen, Edgelists, GraphML, und Netzwerk-Diagramme) für alle Rechtsakte (experimentell!)

Alle Ergebnisse werden im Ordner `output` abgelegt. Zusätzlich werden für alle ZIP-Archive kryptographische Signaturen (SHA2-256 und SHA3-512) berechnet und in einer CSV-Datei hinterlegt.


## Systemanforderungen

- Nur mit Fedora Linux getestet. Vermutlich auch funktionsfähig unter anderen Linux-Distributionen.
- 6 GB Speicherplatz auf Festplatte
- Multi-core CPU empfohlen (die Referenzdatensätze wurden mit 16 threads auf 8 physischen Cores erstellt). 


In der Standard-Einstellung wird das Skript vollautomatisch die maximale Anzahl an Rechenkernen/Threads auf dem System zu nutzen. Die Anzahl der verwendeten Kerne kann in der Konfigurationsatei angepasst werden. Wenn die Anzahl Threads auf 1 gesetzt wird, ist die Parallelisierung deaktiviert.



## Anleitung


### Schritt 1: Ordner vorbereiten

Kopieren Sie bitte den gesamten Source Code in einen leeren Ordner (!), beispielsweise mit:

```
$ git clone https://github.com/seanfobbe/c-dbr
```

Verwenden Sie immer einen separaten und *leeren* Ordner für die Kompilierung. Die Skripte löschen innerhalb von bestimmten Unterordnern (`files/`, `temp/`, `analysis` und `output/`) alle Dateien die den Datensatz verunreinigen könnten --- aber auch nur dort.



### Schritt 2: Installation der Programmiersprache 'R'

Sie müssen die [Programmiersprache R](https://www.r-project.org/) und OpenSSL installiert haben. Normalerweise sind diese in Fedora Linux bereits enthalten, andernfalls führen Sie aus:

```
$ sudo dnf install R openssl
```



### Schritt 3: Installation von 'renv'

Starten sie eine R Session in diesem Ordner, sie sollten automatisch zur Installation von [renv](https://rstudio.github.io/renv/articles/renv.html) aufgefordert werden. `renv` ist ein Tool zur strengen Versionskontrolle von R packages und sichert die Reproduzierbarkeit.





### Schritt 4: Installation von R Packages

Um durch [renv](https://rstudio.github.io/renv/articles/renv.html) alle R packages in der benötigten Version zu installieren, führen Sie in der R session aus:

```
> renv::restore()  # In einer R-Konsole ausführen
```

*Achtung:* es reicht nicht, die Packages auf herkömmliche Art installiert zu haben. Sie müssen dies nochmal über [renv](https://rstudio.github.io/renv/articles/renv.html) tun, selbst wenn die Packages in der normalen Library schon vorhanden sind.



### Schritt 5: Installation von LaTeX

Um die PDF Reports zu kompilieren benötigen Sie eine \LaTeX -Installation. Sie können eine vollständige \LaTeX -Distribution auf Fedora wie folgt installieren:

```
$ sudo dnf install texlive-scheme-full
```

Alternativ können sie das R package [tinytex](https://yihui.org/tinytex/) installieren, welches nur die benötigten \LaTeX\ packages installiert.

```
> install.packages("tinytex")  # In einer R-Konsole ausführen
```

Die für die Referenzdatensätze verwendete \LaTeX -Installation ist `texlive-scheme-full`.





### Schritt 6: Datensatz kompilieren

Falls Sie zuvor den Datensatz schon einmal kompiliert haben (ob erfolgreich oder erfolglos), können Sie mit folgendem Befehl alle Arbeitsdaten im Ordner löschen:

```
> source("delete_all_data.R") # In einer R-Konsole ausführen
```


Den vollständigen Datensatz kompilieren Sie mit folgendem Befehl:

```
> source("run_project.R") # In einer R-Konsole ausführen
```



### Ergebnis

Der Datensatz und alle weiteren Ergebnisse sind nun im Ordner `output/` abgelegt.





## Pipeline visualisieren

Sie können die Pipeline visualisieren, aber nur nachdem sie die zentrale .Rmd-Datei mindestens einmal gerendert haben:

```
> targets::tar_glimpse()     # Nur Datenobjekte
> targets::tar_visnetwork()  # Alle Objekte
```





## Troubleshooting

Hilfreiche Befehle um Fehler zu lokalisieren und zu beheben.

```
> tar_progress()  # Zeigt Fortschritt und Fehler an
> tar_meta()      # Alle Metadaten
> tar_meta(fields = "warnings", complete_only = TRUE)  # Warnungen
> tar_meta(fields = "error", complete_only = TRUE)  # Fehlermeldungen
> tar_meta(fields = "seconds")  # Laufzeit der Targets
```



## Projektstruktur

Die folgende Struktur erläutert die wichtigsten Bestandteile des Projekts. Während der Kompilierung werden weitere Ordner erstellt (`files`, `temp/` `analysis` und `output/`). Die Endergebnisse werden alle in `output/` abgelegt.

 
``` 
.
├── buttons                    # Buttons (nur optische Bedeutung)
├── CHANGELOG.md               # Alle Änderungen
├── config.toml                # Zentrale Konfigurations-Datei
├── data                       # Datensätze, auf denen die Pipeline aufbaut
├── delete_all_data.R          # Löscht den Datensatz und Zwischenschritte
├── functions                  # Wichtige Schritte der Pipeline
├── gpg                        # Persönlicher Public GPG-Key für Seán Fobbe
├── old                        # Alter Code aus früheren Versionen
├── pipeline.Rmd               # Zentrale Definition der Pipeline
├── README.md                  # Bedienungsanleitung
├── renv                       # Versionskontrolle: Executables
├── renv.lock                  # Versionskontrolle: Versionsinformationen
├── reports                    # Markdown-Dateien
├── run_project.R              # Kompiliert den gesamten Datensatz
├── _targets_packages.R        # Versionskontrolle: Packages in targets
└── tex                        # LaTeX-Templates


``` 




 

## Weitere Open Access Veröffentlichungen (Fobbe)

Website — https://www.seanfobbe.de

Open Data  —  https://zenodo.org/communities/sean-fobbe-data/

Source Code  —  https://zenodo.org/communities/sean-fobbe-code/

Volltexte regulärer Publikationen  —  https://zenodo.org/communities/sean-fobbe-publications/



## Kontakt

Fehler gefunden? Anregungen? Kommentieren Sie gerne im Issue Tracker auf GitHub oder schreiben Sie mir eine E-Mail an [fobbe-data@posteo.de](fobbe-data@posteo.de)



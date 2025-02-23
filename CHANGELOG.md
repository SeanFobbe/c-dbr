# Changelog


## Version \version

- Vollständige Aktualisierung der Daten
- Reparatur der Clean Run-Option in der Konfigurationsdatei

## Version 2025-01-07

- Vollständige Aktualisierung der Daten
- Überarbeitung der Dokumentation zu den Varianten des Datensatzes
- Expliziter R Package Version Lock für 2024-06-13 (CRAN Date)
- Überarbeitung des Dockerfiles
- Vereinheitlichung der Komponenten für PDF-Extraktion und Berechnung kryptographischer Hashes
- Vereinfachung der Run-Skripte und stärkere Integration mit Docker Compose
- /tmp in Arbeitsspeicher ausgelagert
- Entfernung von überholtem Source Code
- Entfernung der Tesseract System Library
- Entfernung der Nummerierung von Diagrammen


## Version 2024-10-12

- Vollständige Aktualisierung der Daten
- Überarbeitung der Berechnung linguistischer Kennzahlen
- Erweiterung des Lösch-Skriptes
- Download-Timeout nun bei 300 sek
- Anzahl paralleler Downloads kann separat konfiguriert werden


## Version 2024-07-04

- Vollständige Aktualisierung der Daten
- LIZENZÄNDERUNG: Source Code jetzt unter GNU General Public License Version 3 (GPLv3) oder später lizenziert
- Docker Image auf R 4.4.0 aktualisiert (wegen CVE-2024-27322)
- Python Toolchain entfernt



## Version 2024-04-03

- Vollständige Aktualisierung der Daten
- Aktualisierung der Python Toolchain
- Aktualisierung des Public GPG Keys im Repository



## Version 2024-01-07

- Vollständige Aktualisierung der Daten



## Version 2023-10-03

- Vollständige Aktualisierung der Daten



## Version 2023-07-09

- Vollständige Aktualisierung der Daten
- Konfigurations-Dateien in etc/ verschoben



## Version 2023-04-07

- Vollständige Aktualisierung der Daten
- Gesamte Laufzeitumgebung nun mit Docker versionskontrolliert
- Download-Manifest wird nun spätestens nach 24h Stunden invalidiert, damit keine alten Daten aus früheren Kompilierungen den Prozess zum Absturz bringen
- ZIP-Archiv der TXT-Dateien wird nun auch gehasht
- Verbesserte Formatierung von Warnungen und Fehlermeldungen im Compilation Report
- Veränderung der Download-Reihenfolge
- Falls im ersten Download-Durchlauf Dateien fehlen werden die Folgeversuche nun korrekt durchgeführt
- Die Pipeline mit allen Zwischenergebnissen wird nun automatisch in "output/" archiviert
- Source Code ZIP-Archiv wird nun anhand des git-Manifestes generiert
- README im Hinblick auf Docker aktualisiert
- Struktur des Compilation Reports angepasst, um Warnungen und Fehler prominenter anzuzeigen
- Zusätzliche Unit Tests



## Version 2023-01-05

- Vollständige Aktualisierung der Daten
- Neuer Entwurf des gesamten Source Codes im {targets} Framework
- Zusätzliche Netzwerk-Diagramme für alle Rechtsakte: Sunburst und Circlepacking
- Reguläre Netzwerk-Diagramme nun in blau auf schwarzem Hintergrund
- Manche finale Dateinamen nun mit Trennstrichen statt Pascal Case
- TXT-Konvertierung bricht bei Fehler nicht ab, dokumentiert aber fehlende TXT-Dateien
- Einführung eines separaten Berichts für Robustness Checks



## Version 2022-08-05

- Vollständige Aktualisierung der Daten
- Wenn der Download einer Datei scheitert wird der Kompilierungs-Prozess nicht mehr abgebrochen; Kontrolle über Datenabgleich im Compilation Report
- Diagramme für Norm/Rechtsakt/Metadaten je Periodikum sind nun logarithmisch skaliert
- Technischer Bugfix bei der Berechnung von Netzwerkdiagrammen
- Neuer Unit Test um identische Länge von HTML-Links und extrahierten PDF- und EPUB-Dateinamen
- Fehlende PDF- oder EPUB-Dateien führen nun nicht mehr zu Fehlern in der Pipeline
- Unterscheidung zwischen VBVG 2005 und VBVG 2023



## Version 2022-05-22

- Vollständige Aktualisierung der Daten
- README und CHANGELOG sind nun externe Dateien die bei der Kompilierung automatisch eingebunden werden
- Das für *renv* notwendige Skript activate.R ist im ZIP-Archiv in den Ordner "renv" sortiert



## Version 2022-01-12

- Vollständige Aktualisierung der Daten
- Strenge Versionskontrolle aller R packages
- Der Prozess der Kompilierung ist jetzt detailliert konfigurierbar, insbesondere die Parallelisierung
- Parallelisierung der XML-Parser deaktivert, weil instabil
- Parallelisierung nun vollständig mit *future* statt mit *foreach* und *doParallel* 
- Fehlerhafte Kompilierungen werden beim vor der nächsten Kompilierung vollautomatisch aufgeräumt
- Alle Ergebnisse werden automatisch fertig verpackt in den Ordner \enquote{output} sortiert
- Source Code des Changelogs zu Markdown konvertiert
- Einführung eines Debugging-Modus um die Entwicklung zu beschleunigen



## Version 2021-09-16

- Vollständige Aktualisierung der Daten
- Einfügung von Kurzbezeichnungen der Rechtsakte in die Dateinamen der Netzwerkanalysen
- Einfügung der ID der Rechtsakte in die CSV-Tabelle aller Kurz- und Langtitel

 
 
## Version 2021-07-30
 
- Vollständige Aktualisierung der Daten
- Einführung von neuen Variablen für letzte Änderung (Datum), Neufassung (Datum), Aufhebung (Datum jeweils für Verkündung und Wirkung), Lizenz und hierarchische Ketten von Gliederungsbezeichnungen und -titeln
- Parallelisierung der Downloads um Kompilierung des Korpus zu beschleunigen
- Korrektur bei den Dateinamen der Allgemeinen Eisenbahngesetze: GII weist zwei gleichnamige Rechtsakte (\enquote{Allgemeines Eisenbahngesetz}) nach. Beide werden nun mit dem Jahr ihrer Ausfertigung 1951 und 1993 im Langtitel differenziert. In der Vorversion wurde das neuere AEG noch mit dem Jahr 1994 (Inkrafttreten) beschriftet und das andere AEG ohne Jahreszahl.
- Einführung von Netzwerkanalysen (experimentell!)
- Variablen in CSV-Dateien sind nun semantisch sortiert
- Neues Diagramm für Verteilung von Zeichen
- Falls die XML-Datei mehrere Bemerkungen für Hinweise, Änderung, Neufassung, den Stand oder sonstige Angaben aufweist werden diese nun durch einen vertikalen Strich getrennt (vorher nur mehrere Leerzeichen). 
- Kleinere Korrekturen und Ergänzungen im Codebook


 
## Version 2021-01-05

- Vollständige Aktualisierung der Daten
- Komplette Überarbeitung des Source Codes
- Erstveröffentlichung eines Codebooks
- Einführung der vollautomatischen Erstellung von Datensatz und Codebook
- Einführung von Compilation Reports um den Erstellungsprozess exakt zu dokumentieren
- CSV-Dateien werden durch Parsing der XML-Dateien erstellt
- Automatisierung und deutliche Erweiterung der Qualitätskontrolle
- Einführung von Diagrammen zur Visualisierung von Prüfergebnissen
- Einführung kryptographischer Signaturen
 
 
 
## Version 2020-10-09

- Vollständige Aktualisierung der Daten
- Erstveröffentlichung des Source Codes
- XML-Daten nun fehlerfrei. In Version 2020-07-08 waren XML-Dateien mit Anhängen fehlerhaft.

 
 
## Version 2020-07-08

- Vollständige Aktualisierung der Daten
 
 
 
## Version 2020-05-18

- Erstveröffentlichung
 

#library(groundhog)    # Strenge Versionskontrolle von R packages

#groundhog.library(pkg = "rmarkdown",
#                  date = "2021-02-20")


#'# Vorbereitung

library(rmarkdown)

datestamp <- Sys.Date()





#'# Aufräumen


files.delete <- list.files(pattern = "\\.zip|\\.xml|\\.jpe?g|\\.png|\\.gif|\\.pdf|\\.epub|\\.bib|\\.csv|\\.dtd|\\.spin\\.|\\.log",
                           ignore.case = TRUE)

unlink(files.delete)

unlink("output", recursive = TRUE)
unlink("analyse", recursive = TRUE)
unlink("ANALYSE", recursive = TRUE)
unlink("temp", recursive = TRUE)





#+
#'# Datensatz 
#' 
#' Um den **vollständigen Datensatz** zu kompilieren und einen PDF-Bericht zu erstellen, kopieren Sie bitte alle im Source-Archiv bereitgestellten Dateien in einen leeren Ordner und führen mit R diesen Befehl aus:


begin.compreport <- Sys.time()

rmarkdown::render(input = "01_C-DBR_CorpusCreation.R",
#                  envir = new.env(),
                  output_file = paste0("C-DBR_",
                                       datestamp,
                                       "_CompilationReport.pdf"),
                  output_dir = "output")


end.compreport <- Sys.time()
print(end.compreport-begin.compreport)



#'# Codebook
#' Um das **Codebook** zu kompilieren und einen PDF-Bericht zu erstellen, führen Sie bitte im Anschluss an die Kompilierung des Datensatzes (!) untenstehenden Befehl mit R aus.
#'
#' Bei der Prüfung der GPG-Signatur wird ein Fehler auftreten und im Codebook dokumentiert, weil die Daten nicht mit meiner Original-Signatur versehen sind. Dieser Fehler hat jedoch keine Auswirkungen auf die Funktionalität und hindert die Kompilierung nicht.


rmarkdown::render(input = "02_C-DBR_CodebookCreation.R",
                  envir = new.env(),
                  output_file = paste0("C-DBR_",
                                       datestamp,
                                       "_Codebook.pdf"),
                  output_dir = "output")

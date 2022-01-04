library(rmarkdown)

files.delete <- list.files(pattern = "\\.spin\\.")
unlink(files.delete)


#+
#'### Datensatz 
#' 
#' Um den **vollständigen Datensatz** zu kompilieren und einen PDF-Bericht zu erstellen, kopieren Sie bitte alle im Source-Archiv bereitgestellten Dateien in einen leeren Ordner und führen mit R diesen Befehl aus:

#+ eval = FALSE

rmarkdown::render(input = "01_C-DBR_CorpusCreation.R",
                  envir = new.env(),
                  output_file = paste0("C-DBR_",
                                       Sys.Date(),
                                       "_CompilationReport.pdf"),
                  output_dir = "output")




#'### Codebook
#' Um das **Codebook** zu kompilieren und einen PDF-Bericht zu erstellen, führen Sie bitte im Anschluss an die Kompilierung des Datensatzes (!) untenstehenden Befehl mit R aus.
#'
#' Bei der Prüfung der GPG-Signatur wird ein Fehler auftreten und im Codebook dokumentiert, weil die Daten nicht mit meiner Original-Signatur versehen sind. Dieser Fehler hat jedoch keine Auswirkungen auf die Funktionalität und hindert die Kompilierung nicht.

#+ eval = FALSE

rmarkdown::render(input = "02_C-DBR_CodebookCreation.R",
                  envir = new.env(),
                  output_file = paste0("C-DBR_",
                                       Sys.Date(),
                                       "_Codebook.pdf"),
                  output_dir = "output")

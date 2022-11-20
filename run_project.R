## Parameters

begin <- Sys.time()
datestamp <- Sys.Date()

dir.out <- "output"

config <- RcppTOML::parseTOML("config.toml")


## Create Dir

dir.create(dir.out, showWarnings = FALSE)


## Run full pipeline

rmarkdown::render("pipeline.Rmd",
                  output_file = file.path(dir.out,
                                          paste0(config$project$shortname,
                                                 "_",
                                                 datestamp,
                                                 "_CompilationReport.pdf")))


## Runtime

end <- Sys.time()
print(end-begin)

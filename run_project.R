# Run full pipeline

dir.out <- "output"

dir.create(dir.out, showWarnings = FALSE)

config <- RcppTOML::parseTOML("config.toml")

rmarkdown::render("pipeline.Rmd",
                  output_file = file.path(dir.out,
                                          paste0(config$project$shortname,
                                                 "_",
                                                 Sys.Date(),
                                                 "_CompilationReport.pdf")))


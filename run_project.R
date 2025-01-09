# This script will run the full data pipeline.



# Timing

begin <- Sys.time()




# Set Directory

dir.out <- "output"

dir.create(dir.out, showWarnings = FALSE)




# Load Config

config <- RcppTOML::parseTOML("config.toml")




# Execute Clean Run (see config)


if(config$debug$cleanrun == TRUE){

    source("delete_all_data.sh")

    }



# Run Pipeline

rmarkdown::render("pipeline.Rmd",
                  output_file = file.path(dir.out,
                                          paste0(config$project$shortname,
                                                 "_",
                                                 Sys.Date(),
                                                 "_CompilationReport.pdf")))



# Report Timing

end <- Sys.time()

print(end-begin)

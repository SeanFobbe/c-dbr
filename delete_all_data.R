# This script will delete all data and targets generated by the data set creation process. Run if you wish to do a hard reset for a fresh rerun.

targets::tar_destroy(ask = FALSE)


delete <- c("files/",
            "netzwerke",
            "temp/",
            "analysis/",
            "output/")



unlink(delete, recursive = TRUE)

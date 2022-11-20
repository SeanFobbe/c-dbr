#' Create new LaTeX command

#' @param command.name The name of the new LaTeX command.
#' @param command.body The body of the new LaTeX command.
#'
#' @return A new LaTeX command.


f.latexcommand <- function(command.name,
                           command.body){
    
    newcommand <- paste0("\\newcommand{\\",
                         command.name,
                         "}{",
                         command.body,
                         "}")
    
    return(newcommand)
    
}




#' Write LaTeX definitions to file

#' @param x A list with the relevant entries.
#' @param dir The directory to write the LaTeX definitions file to.
#'
#' @return The filename of a file containing definitions of LaTex commands.


f.latexdefs <- function(x,
                        version,
                        dir){


    ## Make Definitions
    latexdefs <- c("%===========================\n% Definitions \n%===========================",
                   "\n% NOTE: This file was created automatically. Do not change it by hand.\n",
                   "\n%-----Author-----",
                   f.latexcommand("projectauthor", x$project$author),
                   
                   "\n%-----Version-----",
                   f.latexcommand("version", version),
                   
                   "\n%-----Titles-----",
                   f.latexcommand("datatitle", x$project$fullname),
                   f.latexcommand("datashort", x$project$shortname),
                   f.latexcommand("softwaretitle",
                                  paste0("Source Code des \\enquote{", x$project$fullname, "}")),
                   f.latexcommand("softwareshort", paste0(x$project$shortname, "-Source")),
                   
                   "\n%-----Data DOIs-----",
                   f.latexcommand("dataconceptdoi", x$doi$data$concept), 
                   f.latexcommand("dataversiondoi", x$doi$data$version),
                   f.latexcommand("dataconcepturldoi",
                                  paste0("https://doi.org/", x$doi$data$concept)),
                   f.latexcommand("dataversionurldoi",
                                  paste0("https://doi.org/", x$doi$data$version)),
                   
                   "\n%-----Software DOIs-----",
                   f.latexcommand("softwareconceptdoi", x$doi$software$concept),
                   f.latexcommand("softwareversiondoi", x$doi$software$version), 
                   f.latexcommand("softwareconcepturldoi",
                                  paste0("https://doi.org/", x$doi$software$concept)),
                   f.latexcommand("softwareversionurldoi",
                                  paste0("https://doi.org/", x$doi$software$version)),
                   
                   "\n%-----Additional DOIs-----",
                   f.latexcommand("aktenzeichenurldoi",
                                  paste0("https://doi.org/", x$doi$aktenzeichen)),
                   f.latexcommand("personendatenurldoi",
                                  paste0("https://doi.org/", x$doi$personendaten))
                   )

    


    ## Write LaTeX Parameters to disk

    filename <- file.path(dir, "Definitions.tex")
    
    writeLines(latexdefs,
               filename)

    return(filename)


    
}



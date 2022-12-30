#' Extract all links from a html page and return only those indicated by the regular expression.


#' @param URL A valid URL or path to a HTML file.
#' @param regex A valid regular expression.

#' @return A vector of URLs.


f.linkextract_regex <- function(URL,
                                regex){
    tryCatch({

        html <- read_html(URL)
        nodes <- html_nodes(html, "a")
        links <- html_attr(nodes, 'href')
        
        grep(regex,
             links,
             ignore.case = TRUE,
             value = TRUE)
        
    },
    error = function(cond) {
        return(NA)}
    )
}


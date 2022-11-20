#' Inhaltsverzeichnis von GII auslesen

#' @param url URL für das XML-Inhaltsverzeichnis von www.gesetze-im-internet.de

#' @return Absolute URLs für alle XML-Dateien von www.gesetze-im-internet.de.


f.links_xml <- function(url = "https://www.gesetze-im-internet.de/gii-toc.xml"){
    
    xml <- xml2::read_xml(url)

    links <- rvest::html_elements(xml,
                           "link")

    links.xml <- xml2::xml_text(links)


    return(links.xml)

}

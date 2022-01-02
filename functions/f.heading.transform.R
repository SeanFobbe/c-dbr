#'# Transformation von Gliederungs-Metadaten
#' Wird bei der Umwandlung der Metadaten aus dem XML-Format benötigt. Konkret werden hierdurch Werte die nur einmal pro Abschnitt (z.B. Gliederungsüberschriften) hochgerechnet, damit jede Norm die ihr zugehörigen Abschnitts-Metadaten zugewiesen erhält.


f.heading.transform <- function(inputvec){
    
    rep.text <- c("NA", inputvec[is.na(inputvec) == FALSE])
    
    which <- c(1, which(is.na(inputvec) == FALSE), length(inputvec) + 1)
    
    rep.count <- diff(which)
    
    rep <- data.table(rep.text,
                      rep.count)
    
    replist <- vector("list",
                      rep[,.N])
    
    for (i in 1:rep[,.N]){
        
        replist[[i]]<- rep(rep.text[i],
                           rep.count[i])
        
    }
    
    outvec <- unlist(replist)
    return(outvec)    
}

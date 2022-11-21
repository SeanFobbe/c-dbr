

#'## Netzwerk-Analyse (experimentell!)



out.dir <- "test/netzwerke"


subdir <- c("Edgelists",
            "Adjazenz-Matrizen",
            "GraphML",
            "Gliederungstabellen",
            "Netzwerkvisualisierung_Dendrogramm")

lapply(file.path(out.dir,
                 subdir),
       dir.create,
       showWarnings = FALSE,
       recursive = TRUE)



#'### Netzwerk-Analyse durchführen

files.xml <- list.files("test", pattern = "\\.xml$", full.names=TRUE)

errorfiles <- c("BJNR008810961.xml",
                "BJNR010599989.xml",
                "BJNR043410015.xml",
                "BJNR093000015.xml",
                "BJNR135410017.xml",
                "BJNR158720007.xml",
                "BJNR203210978.xml",
                "BJNR203220978.xml",
                "BJNR277700013.xml",
                "BJNR284600017.xml",
                "BJNR364800009.xml",
                "BJNR000939960.xml")

files.xml <- setdiff(files.xml, errorfiles)

length(files.xml)




#https://www.gesetze-im-internet.de/bgb/BJNR001950896.epub

#xml.name <- files.xml[205]

#xml.name <- "XML/BJNR002089971.xml" # problem
#xml.name <- "XML/BJNR001950896.xml" # BGB




#+
#'### Beginn Network Analysis
begin.netanalysis <- Sys.time()


#'### Parallelisierung definieren
#'  Parallele Berechnung funktioniert nicht mit errorfiles; sequentielle Berechnung schon



if(config$parallel$parseNetworks == TRUE){

    plan("multicore",
         workers = fullCores)
    
}else{

    plan("sequential")

     }


#debug
f.network.analysis.robust(files.xml[1],
                          prefix.figuretitle = prefix.figuretitle,
                          caption = caption)



#'### XML Parsen

#+ networkparse, results = 'hide', message = FALSE, warning = FALSE
out.netanalysis <- future_lapply(files.xml,
                                 f.network.analysis.robust,
                                 prefix.figuretitle = prefix.figuretitle,
                                 caption = caption,
                                 future.seed = TRUE)


#'### XML-Dateien bei denen Fehler auftreten

files.xml[grep("error",
               out.netanalysis)]


#'### Ende XML Parsing
end.netanalysis <- Sys.time()

#'### Dauer XML Parsing
end.netanalysis - begin.netanalysis












f.network.analysis.robust <- function(xml.name,
                                      prefix.figuretitle,
                                      caption){

    tryCatch({f.network.analysis(xml.name,
                                 prefix.figuretitle,
                                 caption)},
             error = function(cond) {
                 return(NA)}
             )

}











#xml.name <- "XML/BJNR001950896.xml" # BGB


#xml.name <- "XML/BJNR335610017.xml" # problem
#f.network.analysis(xml.name)



#'### Funktion definieren: f.network.analysis
#' f.network.analysis benötigt  f.kennzahlen.search, f.kennzahlen.collapse und f.kennzahlen.edgelist.


f.network.analysis <- function(xml.name,
                               prefix.figuretitle,
                               caption){

    ##    message(xml.name) # remove after debugging
    XML <- read_xml(xml.name)

    ## Gliederungseinheiten extrahieren
    gliederungseinheit <- html_elements(XML, xpath = "//norm//gliederungseinheit")

    ## Gliederungseinheit splitten
    gliederungseinheit.split <- lapply(gliederungseinheit,
                                       f.split.gliederungseinheit)
    gliederungseinheit.split <- rbindlist(gliederungseinheit.split)

    gliederungseinheit.split <- unique(gliederungseinheit.split, by = "kennzahl")
    
    if (gliederungseinheit.split[,.N] > 0){
        
        ## Abkürzung extrahieren
        jurabk <- html_element(XML, xpath = "//norm//jurabk") %>% xml_text()

        if (length(jurabk) == 0){
            jurabk <- "NA"
        }
        
        ## Titel als Label priorieren, sonst Bezeichnung einsetzen
        node.labels0 <- ifelse(gliederungseinheit.split$titel != "",
                               gliederungseinheit.split$titel,
                               gliederungseinheit.split$bez)

        ## Rechtsakt als Quelle des Netzwerks einfügen
        node.labels <- c(jurabk,
                         node.labels0)

        
        ## Edgelist erstellen
        edgelist <- tryCatch({f.kennzahlen.edgelist(kennzahl = gliederungseinheit.split$kennzahl,
                                                    name = jurabk)},
                             error = function(cond) {
                                 return(0)}
                             )

        ## to do: print errorfilename to disk

        if (length(edgelist) != 0){
            

            ## Node Labels definieren
            nodes.df <-gliederungseinheit.split[,.(kennzahl, titel)]

            addname <- data.table(jurabk,
                                  jurabk)

            setnames(addname, new = c("kennzahl",
                                      "titel"))

            nodes.df <- rbind(addname,
                              nodes.df)

            setnames(nodes.df, new = c("kennzahl",
                                       "label"))

            
            ## Graph aus Edgelist erstellen
            g  <- graph.data.frame(edgelist,
                                   directed = TRUE,
                                   vertices = nodes.df)


            ## Adjazenz-Matrix erstellen
            M.adjacency <- as.matrix(get.adjacency(g,
                                                   edges = F))

            ## Dateiname definieren
            filename <- paste0(gsub("( +)|(/)",
                                    "-",
                                    jurabk),
                               "_",
                               gsub("\\.xml",
                                    "",
                                    basename(xml.name)))

            ## Gliederungstabelle speichern
            fwrite(gliederungseinheit.split,
                   paste0(out.dir,
                          "/Gliederungstabellen/",
                          filename,
                          "_Gliederungstabelle.csv"))
            
            ## Edgelist speichern
            fwrite(edgelist,
                   paste0(out.dir,
                          "/Edgelists/",
                          filename,
                          "_Edgelist.csv"))


            ## Adjazenz-Matrix speichern
            fwrite(M.adjacency,
                   paste0(out.dir,
                          "/Adjazenz-Matrizen/",
                          filename,
                          "_AdjazenzMatrix.csv"))

            
            ## GraphML speichern
            write_graph(g,
                        file = paste0(out.dir,
                                      "/GraphML/",
                                      filename,
                                      ".graphml"),
                        format = "graphml")

            
            ## Diagramm erstellen und speichern
            if (length(V(g)) > 1){
                
                dendrogram <- ggraph(g,
                                      'dendrogram',
                                      circular = TRUE) + 
                    geom_edge_elbow(colour = "grey") + 
                    geom_node_text(aes(label = label),
                                   size = 2,
                                   repel = TRUE)+
                    theme_void()+
                    labs(
                        title = paste(prefix.figuretitle,
                                      "| Struktur des",
                                      jurabk),
                        caption = caption
                    )+
                    theme(
                        plot.title = element_text(size = 50,
                                                  face = "bold"),
                        legend.position = "none",
                        plot.margin = margin(10, 20, 10, 10)
                    )

                ggsave(
                    filename = paste0(out.dir,
                                      "/Netzwerkdiagramme/",
                                      filename,
                                      "_Dendrogramm.pdf"),
                    plot = dendrogram,
                    device = "pdf",
                    scale = 1,
                    width = 50,
                    height = 50,
                    units = "in",
                    dpi = 300,
                    limitsize = FALSE
                )
            }

        }

    }

}










f.split.gliederungseinheit <- function(gliederungseinheit){

    kennzahl <- html_elements(gliederungseinheit, xpath = "gliederungskennzahl") %>% xml_text()
    
    bez <- html_elements(gliederungseinheit, xpath = "gliederungsbez") %>% xml_text()

    ## Newlines, damit Umbrüche in Diagrammen funktionieren
    bez <- gsub(" +",
                "\n",
                bez)
    
    titel <- html_elements(gliederungseinheit, xpath = "gliederungstitel") %>% xml_text()

    titel <- gsub(" +",
                  "\n",
                  titel)
    
    if(length(titel) == 0){
        titel <- NA
    }

    dt <- data.table(kennzahl,
                     bez,
                     titel)
    return(dt)
    
}





#' Funktion definieren: f.kennzahlen.edgelist

#' Erstellt aus einem vektor an Gliederungskennzahlen und dem Gesetzesnamen ein Netzwerk-Diagramm der Inhaltsstruktur. Basiert auf f.kennzahlen.search und f.kennzahlen.collapse.

f.kennzahlen.edgelist <- function(kennzahl, name){

    level <- nchar(kennzahl) / 3

    level.unique <- sort(unique(level))

    depth.begin <- head(seq_along(level.unique), -1)
    depth.end <- depth.begin + 1

    out.list <- vector("list", length(depth.begin))

    for (i in seq_along(depth.begin)){

        lev.begin <- kennzahl[level == depth.begin[i]]
        lev.end <- kennzahl[level == depth.end[i]]

        targets.list <- lapply(lev.begin, f.kennzahlen.search, lev.end)
        out.list[[i]] <- f.kennzahlen.collapse(lev.begin, targets.list)

    }

    out.dt <- rbindlist(out.list)

    ## Add zero level

    if (length(depth.begin != 0)){
        lev1 <- kennzahl[level == depth.begin[1]]
        
        zerolinks <- data.table(rep(name, length(lev1)),
                                lev1)
        
        out.dt <- rbind(zerolinks,
                        out.dt,
                        use.names = FALSE)
    }else{
        lev1 <- kennzahl
        out.dt <- data.table(rep(name, length(lev1)),
                             lev1)
        
    }

    setnames(out.dt,
             new = c("from",
                     "to"))
    
    return(out.dt)

}




#' Funktion definieren: f.kennzahlen.search

f.kennzahlen.search <- function(pattern, targetvec){

    pattern.N <- nchar(pattern)
    target <- substr(targetvec, 1, pattern.N)
    targetvec[grepl(pattern, target, fixed = TRUE)]
    
}



#' f.kennzahlen.collapse

f.kennzahlen.collapse <- function(lev.begin, targets.list){

    out.list <- vector("list", length(targets.list))
    
    for (i in 1:length(targets.list)){

        targets.vector <- targets.list[[i]]
        
        out.list[[i]] <- data.table(rep(lev.begin[i],
                                        length(targets.vector)),
                                    targets.vector)
        
    }

    out.vec <- rbindlist(out.list)
    return(out.vec)
    
}











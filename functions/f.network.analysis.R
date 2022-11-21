

#' Netzwerk-Analyse (experimentell!)
#'
#' Diese Funktionen sind noch experimentell. Bitte immer qualitativ validieren!




### DEBUGGING

## dir.out <- "netzwerke"
## caption <- "test"
## prefix.figuretitle <- "test"
## multicore = FALSE


## grep("BJNR001950896.xml", files.xml)




## out <- f.network.analysis(files.xml = files.xml,
##                           prefix.figuretitle = "test",
##                           caption = "test",
##                           dir.out = "netzwerke",
##                           multicore = FALSE)


### DEBUGGING




f.network.analysis <- function(files.xml,
                               prefix.figuretitle,
                               caption,
                               dir.out,
                               multicore = FALSE,
                               cores = paralell:detectCores()){


    ## Parallel Settings
    if(multicore == TRUE){

        plan("multicore",
             workers = cores)
        
    }else{

        plan("sequential")

    }



    
    ## Create Directories
    
    subdir <- c("Edgelists",
                "Adjazenz-Matrizen",
                "GraphML",
                "Gliederungstabellen",
                "Visualisierung_Dendrogramm",
                "Visualisierung_Circlepack",
                "Visualisierung_Sunburst")

    lapply(file.path(dir.out,
                     subdir),
           dir.create,
           showWarnings = FALSE,
           recursive = TRUE)



    ## XML Parsen

    out.netanalysis <- future_lapply(files.xml,
                                     f.network.analysis.robust,
                                     prefix.figuretitle = prefix.figuretitle,
                                     caption = caption,
                                     dir.out = dir.out,
                                     future.seed = TRUE)
    
    
    errorfiles <- files.xml[grep("error",
                                 out.netanalysis)]

    if(length(errorfiles) > 0){
        
        warning("Errored files:")
        warning(errorfiles)

    }
    

    ## Files Output

    results <- list.files(dir.out, full.names = TRUE, recursive = TRUE)

    return(results)

}








#'### Netzwerk-Analyse durchführen

## files.xml <- list.files("test", pattern = "\\.xml$", full.names=TRUE)

## errorfiles <- c("BJNR008810961.xml",
##                 "BJNR010599989.xml",
##                 "BJNR043410015.xml",
##                 "BJNR093000015.xml",
##                 "BJNR135410017.xml",
##                 "BJNR158720007.xml",
##                 "BJNR203210978.xml",
##                 "BJNR203220978.xml",
##                 "BJNR277700013.xml",
##                 "BJNR284600017.xml",
##                 "BJNR364800009.xml",
##                 "BJNR000939960.xml")

## files.xml <- setdiff(files.xml, errorfiles)

## length(files.xml)




#https://www.gesetze-im-internet.de/bgb/BJNR001950896.epub

#xml.name <- files.xml[205]

#xml.name <- "XML/BJNR002089971.xml" # problem
#xml.name <- "test/BJNR001950896.xml" # BGB
#xml.name <- "test/BJNR001270871.xml" # StGB


## #debug
## f.network.analysis.robust(xml.name,
##                           prefix.figuretitle = prefix.figuretitle,
##                           caption = caption)











f.network.analysis.robust <- function(xml.name,
                                      prefix.figuretitle,
                                      caption,
                                      dir.out){

    tryCatch({f.network.analysis.raw(xml.name,
                                     prefix.figuretitle,
                                     caption,
                                     dir.out = dir.out)},
             error = function(cond) {
                 return(NA)}
             )

}










### DEBUGGING
#xml.name <- "XML/BJNR001950896.xml" # BGB
#xml.name <- "test/BJNR001270871.xml" # StGB

#xml.name <- "XML/BJNR335610017.xml" # problem
#f.network.analysis.raw(xml.name)









#'### Funktion definieren: f.network.analysis.raw
#' f.network.analysis benötigt  f.kennzahlen.search, f.kennzahlen.collapse und f.kennzahlen.edgelist.


f.network.analysis.raw <- function(xml.name,
                                   prefix.figuretitle,
                                   caption,
                                   dir.out){

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
            g  <- igraph::graph.data.frame(edgelist,
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
                   paste0(dir.out,
                          "/Gliederungstabellen/",
                          filename,
                          "_Gliederungstabelle.csv"))
            
            ## Edgelist speichern
            fwrite(edgelist,
                   paste0(dir.out,
                          "/Edgelists/",
                          filename,
                          "_Edgelist.csv"))


            ## Adjazenz-Matrix speichern
            fwrite(M.adjacency,
                   paste0(dir.out,
                          "/Adjazenz-Matrizen/",
                          filename,
                          "_AdjazenzMatrix.csv"))

            
            ## GraphML speichern
            write_graph(g,
                        file = paste0(dir.out,
                                      "/GraphML/",
                                      filename,
                                      ".graphml"),
                        format = "graphml")

            
            ## Dendrogramm
            if (length(V(g)) > 1){

                if (length(V(g)) > 200){
                    
                    labelsize <- 2
                    textsize <- 30
                    captionsize <- 30
                    width  <- 30
                    height  <- 30

                }else if(length(V(g)) > 100){
                    
                    labelsize <- 2
                    textsize <- 20
                    captionsize <- 20
                    width  <- 20
                    height  <- 20

                }else if(length(V(g)) > 50){
                    
                    labelsize <- 2
                    textsize <- 15
                    captionsize <- 15
                    width  <- 15
                    height  <- 15
                    

                }else{
                    
                    labelsize <- 1.5
                    textsize <- 10
                    captionsize <- 10
                    width  <- 10
                    height  <- 10
                    
                    
                }
                
                
                
                dendrogram <- ggraph(g,
                                     'dendrogram',
                                     circular = TRUE) + 
                    geom_edge_elbow(colour = "steelblue2") + 
                    geom_node_text(aes(label = label),
                                   size = labelsize,
                                   repel = TRUE,
                                   color = "white")+
                    theme_void()+
                    labs(
                        title = paste(prefix.figuretitle,
                                      "| Struktur des",
                                      jurabk,
                                      "| Dendrogramm"),
                        caption = caption
                    )+
                    theme(
                        plot.title = element_text(size = textsize,
                                                  face = "bold",
                                                  color = "white"),                        
                        plot.background = element_rect(fill = "black"),                        
                        plot.caption = element_text(size = captionsize,
                                                    color = "white"),
                        legend.position = "none",
                        plot.margin = margin(10, 20, 10, 10)
                    )
                
                ggsave(
                    filename = paste0(dir.out,
                                      "/Visualisierung_Dendrogramm/",
                                      filename,
                                      "_Dendrogramm.pdf"),
                    plot = dendrogram,
                    device = "pdf",
                    scale = 1,
                    width = width,
                    height = height,
                    units = "in",
                    dpi = 300,
                    limitsize = FALSE
                )
            }


            ## Circlepacking-Diagramm
            if (length(V(g)) > 1){

                textsize <- 20
                width  <- 10
                height  <- 10                                
                
                circlepack <- ggraph(g,
                                     'circlepack',
                                     circular = TRUE) + 
                    geom_node_circle(aes(fill = depth),
                                     size = 0.25) + 
                    coord_fixed()+
                    theme_void()+
                    labs(
                        title = paste(prefix.figuretitle,
                                      "| Struktur des",
                                      jurabk,
                                      "| Circlepack"),
                        caption = caption
                    )+
                    theme(
                        plot.title = element_text(size = textsize,
                                                  hjust = 0.5),
                        plot.margin = margin(10, 20, 10, 10)
                    )+
                    guides(
                        fill = guide_legend(title = "Ebene")
                    )
                
                ggsave(
                    filename = paste0(dir.out,
                                      "/Visualisierung_Circlepack/",
                                      filename,
                                      "_Circlepack.pdf"),
                    plot = circlepack,
                    device = "pdf",
                    scale = 1,
                    width = width,
                    height = height,
                    units = "in",
                    dpi = 300,
                    limitsize = FALSE
                )
            }

            


            ## Sunburst-Diagramm
            if (length(V(g)) > 1){

                textsize <- 20
                width  <- 10
                height  <- 10                                
                
                sunburst <- ggraph(g,
                                   "partition",
                                   circular = TRUE) + 
                    geom_node_arc_bar(aes(fill = depth),
                                      size = 0.25)+
                    theme_void()+
                    labs(
                        title = paste(prefix.figuretitle,
                                      "| Struktur des",
                                      jurabk,
                                      "| Sunburst"),
                        caption = caption
                    )+
                    theme(
                        plot.title = element_text(size = textsize,
                                                  hjust = 0.5),
                        plot.margin = margin(10, 20, 10, 10)
                    )+
                    guides(
                        fill = guide_legend(title = "Ebene")
                    )
                
                ggsave(
                    filename = paste0(dir.out,
                                      "/Visualisierung_Sunburst/",
                                      filename,
                                      "_Sunburst.pdf"),
                    plot = sunburst,
                    device = "pdf",
                    scale = 1,
                    width = width,
                    height = height,
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











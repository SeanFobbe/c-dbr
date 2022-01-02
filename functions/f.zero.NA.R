#'# NA in leere Listen-Elemente einsetzen

f.zero.NA <- function(x) if (length(x) == 0){
                             NA_character_
                         }else{
                             paste(x, collapse = " ")}


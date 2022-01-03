#' Computation of SHA2 and SHA3 Hashes

#' Computes SHA2-256 and SHA3-512 hashes for a single file. It returns a data frame with the file name, SHA2-256 hashe and SHA3-512 hash.  The function requires the existence of the openssl (RPM) library on the system.


#' @param x Path to file.


#+
#'## Required: OpenSSL System Library
#' The function requires the existence of the openssl (RPM) library on the system.


multihashes <- function(x){
    sha2.256 <- system2("openssl",
                        paste("sha256",
                              x),
                        stdout = TRUE)
    
    sha2.256 <- gsub("^.*\\= ",
                     "",
                     sha2.256)
    
    sha3.512 <- system2("openssl",
                        paste("sha3-512",
                              x),
                        stdout = TRUE)
    
    sha3.512 <- gsub("^.*\\= ",
                     "",
                     sha3.512)
    
    hashes <- data.frame(x,
                         sha2.256,
                         sha3.512)
    return(hashes)
}

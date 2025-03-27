msg <- function(..., verbose=T) {
    if (verbose) {
        x <- paste(list(...))
        name <- sys.call(sys.parent(1))[[1]]
        cat(paste("[", name, "]", sep=""), date(), x, "\n")
    }
}

#' Write OSCA bod and orm file
#' 
#' This function writes a data frame to a text file, then uses osca to make bod and orm files.
#'
#' @param df A data frame  
#' @param filename a file name with a .txt extension for saving the data frame in osca format.
#' @return A text file with the same name as the input file, a bod file, and an orm file.
#' 
#' @export
osci.write.orm <- function(df, filename){

	stopifnot(is.data.frame(df))
	stopifnot(all(colnames(df)[1:2] == c('FID', 'IID')))
    stopifnot(sub(".*(\\.txt)$", "\\1", filename) == ".txt")

	txt <- paste0(file.no.suffix, ".txt")
	myprofile <- paste0(file.no.suffix, "-myprofile")
	myorm <- paste0(file.no.suffix, "-myorm")

	msg("Writing ORM data to text file:", basename(txt))
	data.table::fwrite(df, 
		file = txt, 
		sep=' ', 
		row.names = F, 
		col.names = T)
	
	msg("Using osca to make bod files:", basename(myprofile))	
	system(paste0("osca --efile ", txt,  
  			" --methylation-beta --make-bod --out ", myprofile))
	
	msg("Using osca to make orm files:", basename(myorm))		
  	system(paste0("osca --befile ", myprofile,
  			" --make-orm --out ", myorm))
}

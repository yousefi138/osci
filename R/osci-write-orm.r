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
#' @param df A data frame with FID and IID as the first two columns.
#' @param filename a file name with a .txt extension for saving the data frame in osca format.
#' @return A text file with the same name as the input file, a bod file, and an orm file.
#' 
#' @export
osci.write.orm <- function(df, filename){

	stopifnot(is.data.frame(df))
	stopifnot(all(colnames(df)[1:2] == c('FID', 'IID')))
    stopifnot(sub(".*(\\.txt)$", "\\1", filename) == ".txt")

	file.no.suffix <- sub("\\.txt$", "", filename)
	myprofile <- paste0(file.no.suffix, "-myprofile")
	myorm <- paste0(file.no.suffix, "-myorm")
    preexist <- list.files()

	msg("Writing ORM data to text file:", filename)
	data.table::fwrite(df, 
		file = filename, 
		sep=' ', 
		row.names = F, 
		col.names = T)
	
	msg("Using osca to make bod files:", myprofile)
    bod <- paste0("osca --efile ", filename,  
  			" --methylation-beta --make-bod --out ", myprofile)	
	system(bod)
	
	msg("Using osca to make orm files:", myorm)		
  	orm <- paste0("osca --befile ", myprofile,
  			" --make-orm --out ", myorm)
    system(orm)

    list(filename = filename,
        myorm = myorm,
        osca.calls = list(bod = bod, orm = orm),
        osca.files = setdiff(list.files(), preexist))
}

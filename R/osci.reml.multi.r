#' Run OSCA multi-orm reml analysis
#' 
#' This function runs the reml analysis in OSCA.
#'
#' @param file.list a file with the name of each orm file to be included in the analysis on a a separate line.
#' @param pheno a phenotype file with FID, IID columns and a phenotype column
#' @param out the base name of the output files
#' @return A text file with the same name as the input file, a bod file, and an orm file.
#' 
#' @export
osci.reml.multi <- function(file.list, pheno, out){
	stopifnot(file.exists(pheno))	
    preexist <- list.files(dirname(file.list))

	msg("Using osca to run multi-orm reml for orms in:", file.list)		
  	reml <- paste0("osca --reml --multi-orm ", file.list, 
		" --pheno ", pheno, " --out ", out )
    system(reml)

    list(file.list = file.list,
        osca.calls = list(reml = reml),
        osca.files = setdiff(list.files(), preexist))
}

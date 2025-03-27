#' Run OSCA reml analysis
#' 
#' This function runs the reml analysis in OSCA.
#'
#' @param myord the base name of the orm files 
#' @param pheno a phenotype file with FID, IID columns and a phenotype column
#' @param out the base name of the output files
#' @return A text file with the same name as the input file, a bod file, and an orm file.
#' 
#' @export
osci.reml <- function(myorm, pheno, out){
	stopifnot(file.exists(pheno))	
	stopifnot(paste0(myorm, ".orm.bin") %in% list.files(dirname(myorm)))
    preexist <- list.files(dirname(myorm))

	msg("Using osca to run reml for:", myorm)		
  	reml <- paste0("osca --reml --orm ", myorm, 
		" --pheno ", pheno, " --out ", out )
    system(reml)

    list(myorm = myorm,
        osca.calls = list(reml = reml),
        osca.files = setdiff(list.files(), preexist))
}


#system(paste0("osca --reml --orm ", "height.orm-myorm", 
#		" --pheno ", "pheno.txt", " --out ", "height-reml" ))


#system(paste0("osca --reml --multi-orm ", file.flist, 
#	" --pheno ", files.pheno[1], " --out ", file.out ))


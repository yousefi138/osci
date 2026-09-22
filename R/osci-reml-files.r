#' Run OSCA REML analysis (filename interface)
#' 
#' Performs REML analysis in OSCA
#' for a single omic 
#' given filenames as inputs.
#'
#' @param myord the base name of the orm files 
#' @param pheno a phenotype file with FID, IID columns and a phenotype column
#' @param out the base name of the output files
#' @return A text file with the same name as the input file, a bod file, and an orm file.
#' 
#' @export
osci.reml.files = function (myorm, pheno, out) {
  stopifnot(file.exists(pheno))
  stopifnot(file.exists(paste0(myorm,".orm.bin")))
  preexist = list.files(dirname(out), full.names=T)
  msg("Using osca to run reml for:", myorm)
  reml <- paste0(
    options("osci.cmd"),
    " --reml --orm ", myorm,
    " --pheno ", pheno,
    " --out ", out)
  check.osca()
  ret = system(reml)
  if (ret != 0) {
    print(reml)
    stop("OSCA REML failed with return code: ", ret)
  }
  list(
    myorm = myorm,
    osca.calls = list(reml = reml),
    osca.files = setdiff(list.files(dirname(out),full.names=T),preexist))
}


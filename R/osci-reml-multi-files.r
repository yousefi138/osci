#' Run OSCA multi-omic REML analysis (filename interface)
#'
#' Performs a multi-omic REML analysis in OSCA
#' given filenames as inputs.
#'
#' @param file.list a file with the name of each orm file to be included in the analysis on a a separate line.
#' @param pheno a phenotype file with FID, IID columns and a phenotype column
#' @param out the base name of the output files
#' @return A text file with the same name as the input file, a bod file, and an orm file.
#'
#' @export
osci.reml.multi.files = function(file.list, pheno, out) {
  stopifnot(file.exists(pheno))
  stopifnot(all(sapply(readLines(file.list), function(fn) file.exists(paste0(fn,".orm.bin")))))
  preexist = list.files(dirname(out),full.names=T)
  osci:::msg("Using osca to run multi-orm reml for orms in:", file.list)
  reml <- paste0(
    options("osci.cmd"),
    " --reml --multi-orm ", file.list,
    " --pheno ", pheno,
    " --out ", out)
  check.osca()
  ret = system(reml)
  if (ret != 0) {
    print(reml)
    stop("OSCA REML failed with return code: ", ret)
  }
  list(
    file.list = file.list,
    osca.calls = list(reml = reml),
    osca.files = setdiff(list.files(dirname(out),full.names=T), preexist))
}

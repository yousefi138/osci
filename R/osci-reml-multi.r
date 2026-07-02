#' Run OSCA multi-omic REML analysis
#' 
#' Performs REML analysis in OSCA
#' for a single omic.
#'
#' @param x Either an ORM list filename or phenotype vector or matrix.
#' If the former, then osci.reml.multi.files is called, otherwise osci.reml.matrices is called.
#' @param ... Additional arguments to be passed to osci.reml.multi.files or osci.reml.matrices.
#' @return Returned outputs depend on the value of x, either osci.reml.multi.files or osci.reml.matrices outputs.
#' 
#' @export
osci.reml.multi = function(x, ...) {
  if (is.character(x))
    osci.reml.multi.files(x, ...)
  else
    osci.reml.matrices(x, ...)
}

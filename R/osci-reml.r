#' Run OSCA REML analysis
#' 
#' Performs REML analysis in OSCA
#' for a single omic.
#'
#' @param x Either an ORM filename or a phenotype vector or matrix.
#' If the former, then osci.reml.files is called, otherwise osci.reml.matrices is called.
#' @param ... Additional arguments to be passed to osci.reml.files or osci.reml.matrices.
#' @return Returned outputs depend on the value of x, either osci.reml.files or osci.reml.matrices outputs.
#' 
#' @export
osci.reml = function(x, ...) {
  if (is.character(x)) 
    osci.reml.files(x, ...)
  else
    osci.reml.matrices(x, ...)
}


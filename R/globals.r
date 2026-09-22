.onLoad = function(libname,pkgname) {
  options("osci.cmd"="osca")
}

container_file_error_msg = paste0(
  "Container file osci.sif is required but does not exist.\n",
  "Use the following command to download osci.sif to the current working directory:\n",
  "$ apptainer pull osci.sif oras://docker.io/matthewsuderman/osci")

#' Choose whether to use the OSCA container or not
#'
#' This function allows the user to choose whether to run OSCA
#' in the current environment or inside the osci container.
#'
#' @param use_container If TRUE, OSCA will be run inside the container, otherwise in the current environment.
#' 
#' @export
osci.use_container = function(use_container=TRUE) {
  if (use_container) {
    options(osci.cmd="CWD=$(realpath $(pwd)); apptainer run -B $CWD:$CWD --pwd $CWD osci.sif osca")
    if (!file.exists("osci.sif"))
      cat("IMPORTANT: ", container_file_error_msg, "\n")
  } else {
    options(osci.cmd="osca")
  }
}

check.osca = function() {
  cmd = options("osci.cmd")[[1]]
  if (grepl("osci.sif", cmd)) {
    if (!file.exists("osci.sif")) 
      stop(container_file_error_msg)
  }
  TRUE
}

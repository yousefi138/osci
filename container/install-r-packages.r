cran = c(
  "remotes",
  "R.utils"
)

remotes = c(
  "yousefi138/osci"
)

names(remotes) = sub(".*/", "", remotes)

stopifnot(getRversion()=="4.6.1")
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2026-07-28"))

## install cran packages
for (pkg in cran)
  if (!require(pkg,character.only=T))
    install.packages(pkg)

## install github packages
for (pkg in names(remotes))
  if (!require(pkg,character.only=T))
    remotes::install_github(remotes[[pkg]])

## check that packages were installed
pkgs = c(cran,bioc,names(remotes))
is_installed = sapply(pkgs, require, character.only=T)
if (any(!is_installed))
  cat("-------------------------------\n",
      "Some packages failed to install: ",
      paste(pkgs[!is_installed], collapse="\n"),
      "\n")

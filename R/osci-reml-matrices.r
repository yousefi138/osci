#' Run OSCA REML analysis (R variable interface)
#'
#' Performs single or multi-omic REML analysis in OSCA
#' for multiple phenotypes in parallel. 
#'
#' @param var A numeric phenotype vector or matrix with samples in rows and phenotypes in columns.
#' @param ... Named omic matrices, one matrix per omic, with samples in columns and features in rows.
#' @param tmp_dir Optional temporary directory for OSCA input and output files. If NULL,
#' a temporary directory will be created using tempfile().
#' @return A list with three elements
#' ('stat'--variance estimates, 'se'--standard errors, and 'test'--test statistics) that collate
#' results across phenotypes and omics.
#'
#' @export
osci.reml.matrices = function(var,...,tmp_dir=NULL) {
  ## list of omics
  omics = list(...)
  ## check inputs
  if (is.null(names(omics)))
    names(omics) = paste0("Omic",1:length(omics))
  if (is.vector(var)) var = cbind(var=var)
  stopifnot(!is.null(colnames(var)))
  stopifnot(all(sapply(omics, ncol) == nrow(var)))
  ## create temporary directory for osca input and output
  if (is.null(tmp_dir)) {
    tmp_dir = tempfile(pattern="osca",tmpdir=".")
    dir.create(tmp_dir)
    on.exit(unlink(tmp_dir, recursive=TRUE))
  }
  ## sample ids
  id = colnames(omics[[1]])
  ## omic relationship matrix files
  orm_fns = file.path(tmp_dir, paste0(names(omics),"-orm.txt"))
  for (i in 1:length(omics)) {
    bin_fn = paste0(orm_fns[i],"-myorm.orm.bin")
    if (file.exists(bin_fn)) {
      cat("Using existing ORM file:", bin_fn, "\n")
      next
    }
    orm = data.frame(
      FID=id,
      IID=id,
      omic=t(omics[[i]]))
    osci.write.orm(orm, orm_fns[i])
  }
  orm_fns_hack = sub(".txt","-myorm", orm_fns)
  files_fn = file.path(tmp_dir, "files.txt")
  writeLines(orm_fns_hack, con=files_fn)
  ## run osca for each phenotype variable
  rets = sapply(colnames(var), function(name) NULL, simplify=F)
  for (pi in 1:ncol(var)) {
    ## phenotype file  
    pheno_fn = file.path(tmp_dir, paste0(colnames(var)[pi], "-pheno.txt"))
    pheno = data.frame(
      FID=id,
      IID=id,
      var=var[,pi])
    write.table(pheno, file=pheno_fn, sep="\t", quote=FALSE, row.names=FALSE,col.names=TRUE)
    ## run osca
    out_fn = file.path(tmp_dir, paste0(colnames(var)[pi],"-osca.txt"))
    if (length(omics) == 1) {
      cat("myorm=",orm_fns_hack[i],"\n")
      ret = osci.reml.files(orm_fns_hack[1], pheno_fn, out=out_fn)
    } else {
      ret = osci.reml.multi.files(files_fn, pheno_fn, out=out_fn)
    }    
    ## save outputs
    ret_fn = paste0(out_fn, ".rsq")
    if (file.exists(ret_fn)) 
      rets[[pi]] = fread(ret_fn,fill=TRUE)
  }
  names(rets) = colnames(var)
  ## collate outputs across phenotypes
  rets = lapply(rets, function(ret) {
    if (is.null(ret)) return(NULL)
    rows = ret$Source
    ret = as.matrix(ret[,c("Variance","SE")])
    rownames(ret) = rows
    ret = ret[!is.na(ret[,"Variance"]),,drop=FALSE]
    stat=ret[!is.na(ret[,"SE"]),"Variance"]
    se=ret[!is.na(ret[,"SE"]),"SE"]
    test=ret[is.na(ret[,"SE"]),"Variance"]
    for (i in 1:length(omics)) {
      names(stat) = sub(paste0("O",i), names(omics)[i], names(stat))
      names(se) = sub(paste0("O",i), names(omics)[i], names(se))
    }
    list(stat=stat, se=se, test=test)
  })
  list(
    stat=do.call(rbind,lapply(rets, function(ret) ret$stat)),
    se=do.call(rbind,lapply(rets, function(ret) ret$se)),
    test=do.call(rbind,lapply(rets, function(ret) ret$test)),
    failed=names(rets)[sapply(rets, is.null)])
}






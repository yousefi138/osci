## ----globals -------------------------------------------------------------
library(osci)

## ----simulate.data-------------------------------------------------------------

set.seed(43)
n <- 200
id <- paste0("x",seq(1, n))
pheno = data.frame(
  FID=id,
  IID=id,
  height=round(rnorm(n,70,5),1))

## 450k DNAm site annotation
annot.450k = read.csv("450k.csv.gz",stringsAsFactors = F)

# simulate a dnam matrix of 1/10 of n = 28794 CpGs available on chromosome 11
# 	on the human 450k array and 1/10 of n =  25161 CpGs on chromosome 3
make.dnam.orm <- function(chr, pheno){
    annot <- read.csv("450k.csv.gz",stringsAsFactors=F)
    if(!missing(chr)) annot <- subset(annot, chromosome == chr)
    annot = annot[sample(1:nrow(annot), nrow(annot)/10),]

    betas <- matrix(data = runif(nrow(annot)*nrow(pheno)), 
                nrow = nrow(pheno), ncol = nrow(annot))
    colnames(betas) <- annot$name

    # make the orm combining pheno IDs and DNAm obs
    orm <- cbind(pheno[, c('FID', 'IID'),drop=F], betas)
    return(orm)
}

chromosomes <- c("chr11", "chr3")
set.seed(42)
orms <- sapply(chromosomes, make.dnam.orm, pheno = pheno, simplify = FALSE)

identical(orms$chr11$FID, orms$chr3$FID)

lapply(orms, function(x) str(x[,1:10]))

## ----make.orm.files------------------------------------------------
library(purrr)

orm.files <- imap(orms, 
                ~ osci.write.orm(df = .x, filename = paste0(.y, ".orm.txt")))

## ----write.pheno.file---------------------------------------------
write.table(pheno, 
    file = "pheno.txt", 
    sep = "\t",
    row.names = FALSE, 
    col.names = TRUE, 
    quote = FALSE)

## ----write.flist-----------------------------------------------------------
files.orm <- sapply(orm.files, function(x) x$myorm)
writeLines(files.orm, con = "files.flist")

## ----run.remls.multi_file_inputs-----------------------------------------------------------
remls <- osci.reml.multi("files.flist", "pheno.txt", out = "height-reml-multi")





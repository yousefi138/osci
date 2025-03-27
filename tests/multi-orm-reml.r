## ----globals -------------------------------------------------------------
library(osci)

## ----simulate.data-------------------------------------------------------------

# make a pheno dataset from r dataset "women" looking at the height variable
data(women) 
id <- paste0("x",seq(1, nrow(women)))
pheno <- data.frame(
            FID = id,
            IID = id,
            height = women$height) 

# simulate a dnam matrix of n=28794 CpGs available on chromosome 11
# 	on the human 450k array  and n= 25161 CpGs on chromosome 3

# remotes::install_github("perishky/meffil") # for meffil install
make.dnam.orm <- function(chr, pheno, featureset = "450k"){
    annot <-  meffil::meffil.get.features(featureset = featureset)
    if(!missing(chr)) annot <- subset(annot, chromosome == chr)

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
# 'data.frame':   15 obs. of  10 variables:
#  $ FID       : chr  "x1" "x2" "x3" "x4" ...
#  $ IID       : chr  "x1" "x2" "x3" "x4" ...
#  $ cg00035864: num  0.912 0.972 0.366 0.196 0.953 ...
#  $ cg00050873: num  0.96 0.98 0.59 0.127 0.981 ...
#  $ cg00061679: num  0.939 0.623 0.48 0.423 0.281 ...
#  $ cg00063477: num  0.95 0.695 0.736 0.516 0.445 ...
#  $ cg00121626: num  0.941 0.381 0.516 0.761 0.885 ...
#  $ cg00212031: num  0.1885 0.793 0.0778 0.929 0.2489 ...
#  $ cg00213748: num  0.0221 0.3116 0.6584 0.891 0.885 ...
#  $ cg00214611: num  0.6493 0.997 0.6444 0.8979 0.0134 ...
# 'data.frame':   15 obs. of  10 variables:
#  $ FID       : chr  "x1" "x2" "x3" "x4" ...
#  $ IID       : chr  "x1" "x2" "x3" "x4" ...
#  $ cg00035864: num  0.0517 0.5162 0.5453 0.9457 0.9669 ...
#  $ cg00050873: num  0.956 0.348 0.17 0.163 0.647 ...
#  $ cg00061679: num  0.402 0.753 0.516 0.428 0.444 ...
#  $ cg00063477: num  0.3414 0.4601 0.6525 0.0908 0.6897 ...
#  $ cg00121626: num  0.7535 0.0794 0.6779 0.2691 0.6606 ...
#  $ cg00212031: num  0.71 0.0499 0.0188 0.3328 0.5917 ...
#  $ cg00213748: num  0.4954 0.1112 0.8084 0.1317 0.0343 ...
#  $ cg00214611: num  0.12 0.938 0.408 0.548 0.108 ...

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

## ----run.remls-----------------------------------------------------------
remls <- osci.reml.multi("files.flist", "pheno.txt", out = "height-reml-multi")


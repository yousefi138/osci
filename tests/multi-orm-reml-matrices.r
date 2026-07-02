## ----globals -------------------------------------------------------------
library(osci)

## ----simulate.data-------------------------------------------------------------

## simulate DNA methylation for different automobiles
set.seed(42)
n=200
pheno = data.frame(
  weight=rnorm(n,180,15),
  height=rnorm(n,70,5),
  hr=rnorm(n,70,10))
rownames(pheno) = paste("x",1:nrow(pheno),sep="")

## 450k DNAm site annotation
annot.450k = read.csv("450k.csv.gz",stringsAsFactors = F)

# simulate a dnam matrix of 1/10 of n = 28794 CpGs available on chromosome 11
# 	on the human 450k array and 1/10 of n =  25161 CpGs on chromosome 3
simulate.meth = function(chr, pheno, annot=annot.450k) {
  if(!missing(chr)) annot = subset(annot, chromosome=chr)
  annot = annot[sample(1:nrow(annot), nrow(annot)/10),]
  betas = matrix(
    data=runif(nrow(annot)*nrow(pheno)), 
    ncol=nrow(pheno),
    nrow=nrow(annot))
  rownames(betas) = annot$name
  colnames(betas) = rownames(pheno)
  betas
}

chromosomes = c("chr11", "chr3")
set.seed(42)
meth = sapply(chromosomes, simulate.meth, pheno=pheno, simplify=FALSE)

## ----run.remls.multi-----------------------------------------------------------

remls = osci.reml.multi(pheno, chr11=meth$chr11, chr3=meth$chr3)
print(remls)


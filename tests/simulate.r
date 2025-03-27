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
# 	on the human 450k array

# remotes::install_github("perishky/meffil") # for meffil install
annot <- subset(
            meffil::meffil.get.features(featureset = "450k"),
                chromosome == "chr11")

set.seed(42)
betas <- matrix(data = runif(nrow(annot)*nrow(pheno)), 
				nrow = nrow(pheno), ncol = nrow(annot))
colnames(betas) <- annot$name

# make the orm combining pheno IDs and DNAm obs
orm <- cbind(pheno[, c('FID', 'IID'),drop=F], betas)

dim(orm)
# [1]    15 28796

# show structure of the first 10 vars
str(orm[,1:10])
#'data.frame':   15 obs. of  10 variables:
# $ FID       : chr  "x1" "x2" "x3" "x4" ...
# $ IID       : chr  "x1" "x2" "x3" "x4" ...
# $ cg00000924: num  0.915 0.937 0.286 0.83 0.642 ...
# $ cg00005619: num  0.94 0.978 0.117 0.475 0.56 ...
# $ cg00007644: num  0.7376 0.81106 0.38811 0.68517 0.00395 ...
# $ cg00007981: num  0.958 0.888 0.64 0.971 0.619 ...
# $ cg00009053: num  0.676 0.983 0.76 0.566 0.85 ...
# $ cg00009088: num  0.71936 0.00788 0.37549 0.51441 0.00157 ...
# $ cg00012397: num  0.667427 0.000239 0.20857 0.933034 0.925645 ...
# $ cg00013006: num  0.96261 0.73986 0.73325 0.53576 0.00227 ...

## ----make.orm.files------------------------------------------------
orm.files <- osci.write.orm(df = orm, filename = "height.orm.txt")

# orm.files
# $filename
# [1] "height.orm.txt"
# 
# $myorm
# [1] "height.orm-myorm"
# 
# $osca.calls
# $osca.calls$bod
# [1] "osca --efile height.orm.txt --methylation-beta --make-bod --out height.orm-myprofile"
# 
# $osca.calls$orm
# [1] "osca --befile height.orm-myprofile --make-orm --out height.orm-myorm"
# 
# $osca.files
# [1] "height.orm-myorm_1_1.log"     "height.orm-myorm.orm.bin"    
# [3] "height.orm-myorm.orm.id"      "height.orm-myorm.orm.N.bin"  
# [5] "height.orm-myprofile_1_1.log" "height.orm-myprofile.bod"    
# [7] "height.orm-myprofil

## ----write.pheno.file---------------------------------------------
write.table(pheno, 
    file = "pheno.txt", 
    sep = "\t",
    row.names = FALSE, 
    col.names = TRUE, 
    quote = FALSE)

## ----run remls -------------------------------------------------------------
remls <- osci.reml(orm.files$myorm, "pheno.txt", out = "height-reml")




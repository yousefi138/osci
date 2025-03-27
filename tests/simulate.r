## ----globals -------------------------------------------------------------
packages <- c("tidyverse", "data.table") 
lapply(packages, require, character.only=T)

## ----simulate.data-------------------------------------------------------------

# make a pheno dataset from r dataset "women" looking at the height variable
data(women) 
pheno <- women %>%
			mutate(
				FID = paste0("x",seq(1, nrow(women))),
				IID = FID) %>%
			dplyr::select(FID, IID, height)			

# simulate a dnam matrix of n=28794 CpGs available on chromosome 11
# 	on the human 450k array

# remotes::install_github("perishky/meffil") # for meffil install
annot <- meffil::meffil.get.features(featureset = "450k") %>%
			filter(chromosome == "chr11")

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

## ----write.orms -------------------------------------------------------------
msg <- function(..., verbose=T) {
    if (verbose) {
        x <- paste(list(...))
        name <- sys.call(sys.parent(1))[[1]]
        cat(paste("[", name, "]", sep=""), date(), x, "\n")
    }
}

write.orm <- function(df, file.no.suffix){

	stopifnot(is.data.frame(df))
	stopifnot(all(colnames(df)[1:2] == c('FID', 'IID')))

	txt <- paste0(file.no.suffix, ".txt")
	myprofile <- paste0(file.no.suffix, "-myprofile")
	myorm <- paste0(file.no.suffix, "-myorm")

	msg("Writing ORM data to text file:", basename(txt))
	data.table::fwrite(df, 
		file = txt, 
		sep=' ', 
		row.names = F, 
		col.names = T)
	
	msg("Using osca to make bod files:", basename(myprofile))	
	system(paste0("osca --efile ", txt,  
  			" --methylation-beta --make-bod --out ", myprofile))
	
	msg("Using osca to make orm files:", basename(myorm))		
  	system(paste0("osca --befile ", myprofile,
  			" --make-orm --out ", myorm))
}

write.orm(df = orm, file.no.suffix = "height.orm")
list.files()
# [1] "height.orm-myorm_1_1.log"     "height.orm-myorm.orm.bin"
# [3] "height.orm-myorm.orm.id"      "height.orm-myorm.orm.N.bin"
# [5] "height.orm-myprofile_1_1.log" "height.orm-myprofile.bod"
# [7] "height.orm-myprofile.oii"     "height.orm-myprofile.opi"
# [9] "height.orm.txt"

write_delim(pheno, file = "height.pheno.txt", quote = "none")
list.files()
# [1] "height.orm-myorm_1_1.log"     "height.orm-myorm.orm.bin"
# [3] "height.orm-myorm.orm.id"      "height.orm-myorm.orm.N.bin"
# [5] "height.orm-myprofile_1_1.log" "height.orm-myprofile.bod"
# [7] "height.orm-myprofile.oii"     "height.orm-myprofile.opi"
# [9] "height.orm.txt"               "height.pheno.txt"

## ----run remls -------------------------------------------------------------
system(paste0("osca --reml --orm ", "height.orm-myorm", 
		" --pheno ", "height.pheno.txt", " --out ", "height-reml" ))

list.files()
# [1] "height-reml_1_1.log"          "height-reml.rsq"
# [3] "height.orm-myorm_1_1.log"     "height.orm-myorm.orm.bin"
# [5] "height.orm-myorm.orm.id"      "height.orm-myorm.orm.N.bin"
# [7] "height.orm-myprofile_1_1.log" "height.orm-myprofile.bod"
# [9] "height.orm-myprofile.oii"     "height.orm-myprofile.opi"
#[11] "height.orm.txt"               "height.pheno.txt"
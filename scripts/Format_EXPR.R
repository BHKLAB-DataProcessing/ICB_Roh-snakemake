library(data.table)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

expr = read.csv( file.path(input_dir, "EXPR.txt.gz") , stringsAsFactors=FALSE  , sep="\t" , dec="," )
rownames(expr) = expr[,"sample"]
expr = data.frame(t( expr[ , -(1:5)] ))
expr[, colnames(expr)] <- sapply(expr[, colnames(expr)], as.numeric)
# colnames(expr) <- paste0("P.", str_replace_all(colnames(expr), "\\D(?=.*)", ""))
# expr <- as.data.frame(expr)
expr = data.frame(expr[ , grep("A" , colnames(expr) ) ])
colnames(expr) <- str_replace(colnames(expr), 'X', '')
colnames(expr) = sapply( colnames(expr) , function(x){ paste( "P.", unlist(strsplit( x , "A" , fixed=TRUE))[1] , sep="" ) } )

write.table( expr , file=file.path(output_dir, "EXPR.csv"), quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )

library(data.table)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" )

patient = paste( "P." , sort( unique( clin$Patient.ID ) ) , sep="" )

# rna = colnames( fread( file.path(output_dir, "EXPR.csv") , stringsAsFactors=FALSE  , sep=";" )[ , -1 ] ) 
rna = colnames(read.csv(file.path(output_dir, "EXPR.csv"), sep=';'))
# snv = sort( unique( as.matrix( fread( file.path(input_dir, "SNV.csv") , stringsAsFactors=FALSE , header=TRUE, fill=TRUE , sep=";" ) )[ , 1 ] ) )
snv_df <- read.csv( file.path(output_dir, "SNV.csv"), sep=";" )
snv = sort( unique( snv_df$Sample ) ) 

case = as.data.frame( cbind( patient , rep( 0 , length(patient) ) , rep( 0 , length(patient) ) , rep( 0 , length(patient) ) ) )
colnames(case) = c( "patient" , "snv" , "cna" , "expr" )
rownames(case) = patient

case$snv = as.numeric( as.character( case$snv ) )
case$cna = as.numeric( as.character( case$cna ) )
case$expr = as.numeric( as.character( case$expr ) )

for( i in 1:nrow(case)){
	if( rownames(case)[i] %in% snv ){
		case$snv[i] = 1
	}
	if( rownames(case)[i] %in% rna ){
		case$expr[i] = 1
	}
}

case = case[ rowSums(case[ , 2:4])>0 , ]

write.table( case , file=file.path(output_dir, "cased_sequenced.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

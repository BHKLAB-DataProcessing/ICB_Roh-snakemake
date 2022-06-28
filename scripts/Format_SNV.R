library(stringr)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

input_dir <- "~/Documents/GitHub/Pachyderm/PredictIO_ICB/data/ICB_Roh-data"

snv = read.csv( gzfile( file.path(input_dir, "SNV.txt.gz") , "rt" ), stringsAsFactors=FALSE , sep="\t" )

data = cbind( snv[ , c("start" , "Sample" , "Hugo_Symbol", "Variant_Class","ref_allele", "alt_allele"  ) ] ,
				sapply( snv[ , "chrom" ] , function(x){ paste( "chr" , x , sep="" ) } )
			)

colnames(data) = c( "Pos" , "Sample" , "Gene" , "Effect" , "Ref" , "Alt" , "Chr" )

data = data[ , c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" ) ]

data$Ref = ifelse( data$Ref %in% "-" , "" , data$Ref )
data$Alt = ifelse( data$Alt %in% "-" , "" , data$Alt )

data = cbind ( data , apply( data[ , c( "Ref", "Alt" ) ] , 1 , function(x){ ifelse( nchar(x[1]) != nchar(x[2]) , "INDEL", "SNV") } ) )
colnames(data) = c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" , "MutType"  )

# data$Sample <- paste0("P.", str_replace_all(data$Sample, "\\D(?=.*)", ""))

data = data[ grep("A" , data$Sample ) , ]
data$Sample = sapply( data$Sample  , function(x){ paste( "P.", unlist(strsplit( x , "A" , fixed=TRUE))[1] , sep="" ) } )

data$Effect[ data$Effect %in% "" ] = NA
data$Effect[ data$Effect %in% "Missense" ] = "Missense_Mutation"
data$Effect[ data$Effect %in% "Nonsense" ] = "Nonsense_Mutation"
data$Effect[ data$Effect %in% "stoploss SNV" ] = "Stop_Codon_Del"

data$Gene[ grep( ";" , data$Gene ) ] = sapply( data$Gene[ grep( ";" , data$Gene ) ] , function( x ) unlist( strsplit( x , ";" , fixed=TRUE ) )[1] )

data = unique( data )

write.table( data , file=file.path(output_dir, "SNV.csv"), quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

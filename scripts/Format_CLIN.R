args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t")

clin = cbind( clin[ , c( "Patient.ID","Sex","Age","anti.CTLA.4.RECIST..CR..PR..SD..PD.","Overall.Survival","Dead..Y.N." ) ] ,
	 "Melanoma" , "CTLA4" , NA , NA , NA , NA , NA , NA , NA , NA , NA )
colnames(clin) = c( "patient" , "sex" , "age" , "recist" , "t.os" , "os"  , 
					"primary" , "drug_type" , "histo" , "stage" , "t.pfs" , "pfs" , "dna" , "rna" , "response.other.info" , "response")

clin$patient = paste( "P." , clin$patient , sep="" )
clin$t.os = clin$t.os / 30.5
clin$os = ifelse(clin$os %in% "Y" , 1 , 0 )
clin$response = Get_Response( data=clin )

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
clin = clin[ clin$patient %in% case$patient , ]
clin$dna[ clin$patient %in% case[ case$snv %in% 1 , ]$patient ] = "wes"

clin = clin[ , c("patient" , "sex" , "age" , "primary" , "histo" , "stage" , "response.other.info" , "recist" , "response" , "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os" ) ]

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

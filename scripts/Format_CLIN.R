library(tibble)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]
annot_dir <- args[3]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

clin_original = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t")
selected_cols <- c( "Patient.ID","Sex","Age","anti.CTLA.4.RECIST..CR..PR..SD..PD.","Overall.Survival","Dead..Y.N." )
clin = cbind( clin_original[ , selected_cols ] ,"Melanoma" , "CTLA4" , NA , NA , NA , NA , NA , NA , NA , NA , NA )
colnames(clin) = c( "patient" , "sex" , "age" , "recist" , "t.os" , "os"  , 
					"primary" , "drug_type" , "histo" , "stage" , "t.pfs" , "pfs" , "dna" , "rna" , "response.other.info" , "response")

clin$patient = paste( "P." , clin$patient , sep="" )
clin_original$Patient.ID <- paste0("P.", clin_original$Patient.ID)

clin$t.os = clin$t.os / 30.5
clin$os = ifelse(clin$os %in% "Y" , 1 , 0 )
clin$response = Get_Response( data=clin )

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )

clin = clin[ clin$patient %in% case$patient , ]
clin_original <- clin_original[clin_original$Patient.ID %in% case$patient, ]

clin$dna[ clin$patient %in% case[ case$snv %in% 1 , ]$patient ] = "wes"
clin = clin[ , c("patient" , "sex" , "age" , "primary" , "histo" , "stage" , "response.other.info" , "recist" , "response" , "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os" ) ]

clin <- format_clin_data(clin_original, 'Patient.ID', selected_cols, clin)

# Tissue and drug annotation
annotation_tissue <- read.csv(file=file.path(annot_dir, 'curation_tissue.csv'))
clin <- annotate_tissue(clin=clin, study='Roh', annotation_tissue=annotation_tissue, check_histo=FALSE)

clin <- add_column(clin, unique_drugid='', .after='unique_tissueid')

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

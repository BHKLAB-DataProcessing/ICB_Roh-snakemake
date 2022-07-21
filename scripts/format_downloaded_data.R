library(data.table)
library(readxl) 
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]

unzip(file.path(work_dir, 'aah3560_tables_s1_to_s18.zip'), exdir=file.path(work_dir))

# CLIN.txt
clin <- read_excel(
  file.path(work_dir, 'Roh_aah3560_Tables S1 to S18', 'aah3560_Tables S1 to S18.xlsx'), 
  sheet='Table S1B. Patient'
)
colnames(clin) <- clin[2, ]
clin <- clin[-c(1:2), ]

colnames(clin) <- str_replace_all(colnames(clin), '\\W', '.')
treatments <- c('anti.CTLA.4.', 'anti.PD.1.')
colnames(clin)[colnames(clin) == 'Treated..Y.N.'] <- str_c(treatments, colnames(clin)[colnames(clin) == 'Treated..Y.N.'])
colnames(clin)[colnames(clin) == 'RECIST..CR..PR..SD..PD.'] <- str_c(treatments, colnames(clin)[colnames(clin) == 'RECIST..CR..PR..SD..PD.'])
colnames(clin)[colnames(clin) == '..of.prior.or.concurrent.therapies'] <- str_c(treatments, colnames(clin)[colnames(clin) == '..of.prior.or.concurrent.therapies'])
colnames(clin)[colnames(clin) == 'Description.of.prior.or.concurrent.therapies'] <- str_c('anti.CTLA.4.', colnames(clin)[colnames(clin) == 'Description.of.prior.or.concurrent.therapies'])
colnames(clin)[colnames(clin) == 'Description.of.prior.orconcurrenttherapies'] <- str_c('anti.PD.1.', colnames(clin)[colnames(clin) == 'Description.of.prior.orconcurrenttherapies'])

write.table( clin , file=file.path(work_dir, 'CLIN.txt') , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )

# EXPR.txt.gz
expr <- read_excel(
  file.path(work_dir, 'Roh_aah3560_Tables S1 to S18', 'aah3560_Tables S1 to S18.xlsx'), 
  sheet='Table S8. NanoString counts'
)
gz <- gzfile(file.path(work_dir, 'EXPR.txt.gz'), "w")
write.table( expr , file=gz , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
close(gz)

# SNV.txt.gz
snv <- read_excel(
  file.path(work_dir, 'Roh_aah3560_Tables S1 to S18', 'aah3560_Tables S1 to S18.xlsx'), 
  sheet='Table S4. point muts_indels'
)
gz <- gzfile(file.path(work_dir, 'SNV.txt.gz'), "w")
write.table( snv , file=gz , quote=FALSE , sep="\t" , col.names=TRUE , row.names=FALSE )
close(gz)

file.remove(file.path(work_dir, 'aah3560_tables_s1_to_s18.zip'))
unlink(file.path(work_dir, "Roh_aah3560_Tables S1 to S18"), recursive = TRUE)
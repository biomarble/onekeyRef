##############################################
#####   Beijing PlantTech Technologies  ######
#####     Email:tech@planttech.com.cn   ######
##############################################
suppressPackageStartupMessages(library(yaml))
yaml.file <- yaml.load_file('configs/config.yaml')

output.path <- file.path(yaml.file$FINALOUTPUT,  "2.expression")
infile1=paste0(yaml.file$FINALOUTPUT,"/2.expression/all.sample.FPKM.tsv")

dat1=read.table(infile1,sep="\t",header=T,row.names=1)
cor1=cor(dat1,method='pearson')
write.table(cor1,file=paste0(output.path,"/Sample.CorCoef.tsv"),sep="\t",quote=F,col.names=NA,row.names=T)

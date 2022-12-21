##############################################
#####   Beijing PlantTech Technologies  ######
#####     Email:tech@planttech.com.cn   ######
##############################################
suppressPackageStartupMessages(library(DESeq2))
suppressPackageStartupMessages(library(EBSeq))
suppressPackageStartupMessages(library(yaml))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tibble))

DEGAnalysis_DESeq2 <-  function (control,treat){
  countMatrix=read.delim(infile,header=T,row.names=1,sep="\t")
  meta.data=meta.data%>% filter(group %in% c(control,treat))
  meta.data$group=as.factor(meta.data$group)
  countMatrix=countMatrix%>% select(meta.data$sample)
  dds <- DESeqDataSetFromMatrix(countMatrix, colData=meta.data, ~ group)
  dds <- dds[ rowSums(counts(dds)) > 1,]
  dds <- DESeq(dds)
  res <- results(dds,contrast = c("group",treat,control))
  out=select(as.data.frame(res),'baseMean','log2FoldChange','pvalue','padj')
  out=rownames_to_column(out,'ID')
  out=filter(out,!is.na(padj))
  if(useFDR){
    diff=filter(out,padj<cut,abs(log2FoldChange)>=abs(log2(FCcut)))
  }else{
    diff=filter(out,pvalue<cut,abs(log2FoldChange)>=abs(log2(FCcut)))
  }
  write.table(out, paste(output.path, '/',control, '.vs.', treat, '.AllGene.tsv', sep = ''), row.names = F, quote = FALSE, sep = '\t')
  write.table(diff, paste(output.path, '/',control, '.vs.', treat, '.DEG.tsv', sep = ''), row.names = F, quote = FALSE, sep = '\t')
  write.table(diff$ID, paste(output.path, '/', control, '.vs.', treat, '.DEGlist.tsv', sep = ''), row.names = F, quote = FALSE, sep = '\t')
}
DEGAnalysis_EBSeq <-  function (control,treat){
  countMatrix=read.delim(infile,header=T,row.names=1,sep="\t")
  meta.data=meta.data%>% filter(group %in% c(control,treat))
  meta.data$group=as.factor(meta.data$group)
  countMatrix=countMatrix%>% select(meta.data$sample)
  countMatrix=as.matrix(countMatrix)
  Sizes=MedianNorm(countMatrix)
  EBOut = EBTest(countMatrix,Conditions=meta.data$group,sizeFactors=Sizes, maxround=5)
  FCCut=1/FCcut
  EBDERes=GetDEResults(EBOut, FDR=cut,Threshold_FC=FCCut)
  FDR=1-EBOut$PPMat[,'PPDE']
  GeneFC <- PostFC(EBOut)
  outFC=GeneFC$PostFC
  if(GeneFC$Direction == paste0(control,' Over ',treat)){
    outFC=1/outFC
  }
  out.remain=cbind(log2(outFC),FDR)
  
  nFilt=length(EBOut$AllZeroIndex)
  out.filt=cbind(rep(NA,nFilt),rep(NA,nFilt))
  row.names(out.filt)=names(EBOut$AllZeroIndex)
  out=rbind(out.remain,out.filt)  
  colnames(out)=c('log2(FoldChange)','FDR')
  out=rownames_to_column(as.data.frame(out),'ID')
  diff=out[match(EBDERes$DEfound,out$ID),]
  
  write.table(out, paste(output.path, '/',control, '.vs.', treat, '.AllGene.tsv', sep = ''), row.names = F, quote = FALSE, sep = '\t')
  write.table(diff, paste(output.path, '/',control, '.vs.', treat, '.DEG.tsv', sep = ''), row.names = F, quote = FALSE, sep = '\t')
  write.table(diff$ID, paste(output.path, '/', control, '.vs.', treat, '.DEGlist.tsv', sep = ''), row.names = F, quote = FALSE, sep = '\t')
}

yaml.file <- yaml.load_file('configs/config.yaml')
controls <- yaml.file$CONTROL 
treats <- yaml.file$TREAT  
useFDR <- yaml.file$useFDR  
cut <- yaml.file$cut 
FCcut <- yaml.file$FCcut
meta.file <- yaml.file$SAMPLEINFO
output.path <- file.path(yaml.file$FINALOUTPUT,  "3.DEG")
infile=paste0(yaml.file$FINALOUTPUT,"/2.expression/all.sample.count.tsv")

if(!dir.exists(output.path)){dir.create(path=output.path,recursive = T)}

meta.data <- read.csv(meta.file, header = TRUE, sep = '\t',stringsAsFactors = F)
group.all <- meta.data$group
num.control <- length(controls) 
num.treat <- length(treats)

if (num.control != num.treat) {
  message("致命错误: 对照组数目与处理组数目不对应!")
  message("请仔细检查config.yaml文件")
  quit(save = 'no')
}
num.comparison <- num.control
for (ith.comparison in c(1:num.comparison)) {
  control <- controls[ith.comparison]
  treat <- treats[ith.comparison]
  sn1=sum(group.all==control)
  sn2=sum(group.all==treat)
  name=paste0(control,".vs.",treat)
  if(min(sn1,sn2)==1){
    message(paste0("EBSeq软件分析：",name))
    DEGAnalysis_EBSeq(control, treat)
  }else{
    message(paste0("DESeq2软件分析：",name))
    DEGAnalysis_DESeq2(control, treat)
  }
}
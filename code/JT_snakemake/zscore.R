# redirect all output to the log file
log <- file(snakemake@log[[1]])
sink(log, append = TRUE)
sink(log, append = TRUE, type = "message")

# Load in libraries
library(splines)
library(metap)
library(pheatmap)
library(RColorBrewer)
library(viridisLite)

# Read in all counts file
counts<-read.table(snakemake@input[["counts_raw"]],sep="\t",header=TRUE)
# Set plasmid variable from snakemake config
plasmid<-snakemake@config[["plasmid"]]
# Get a list of treatment data column names from comma separated config string
treatment<-make.names(unlist(strsplit(snakemake@params$treatment,",")))
# Get a list of control data column names from comma separated config string
control<-make.names(unlist(strsplit(snakemake@params$control,",")))

# DEBUG
# print date to make sure output updates
cat(format(Sys.time(), "%a %b %d %X %Y"), '\n\n')

count.matrix<-counts[,3:ncol(counts)]
# Run normalization: log2((x / sum(x) * 1E6) + 1)
counts.normalized<-apply(count.matrix,2,function(x){log2((x/sum(x)*1E6)+1)})

# Get standard deviation of plasmid data from normalized values
plasmid.sd<-sd(counts.normalized[,plasmid])
# Get mean of plasmid data from normalized values
plasmid.mean<-mean(counts.normalized[,plasmid])
# Make table of gene names from genes in count data
tab<-table(counts$Gene)

counts.lfc<-apply(counts.normalized,2,function(x){x-counts.normalized[,plasmid]})[,colnames(counts.normalized)!=plasmid]
treatment.lfc<-counts.lfc[,treatment]
control.lfc<-counts.lfc[,control]

zm<-matrix(nc=ncol(treatment.lfc),nr=length(unique(counts$Gene)))
fdrm<-matrix(nc=ncol(treatment.lfc),nr=length(unique(counts$Gene)))
res<-matrix(nc=ncol(treatment.lfc),nr=nrow(treatment.lfc))

pdf(snakemake@output[["zscoreplots"]],height=2.5,width=2.5,pointsize=8)
for(i in 1:ncol(treatment.lfc)){
	y<-treatment.lfc[,i]
	c<-control.lfc[,i]
	data<-data.frame(treatment=y,control=c,Gene=counts$Gene)
	data<-data[order(data$control),]
	smoothScatter(y~c,xlab=control[i],ylab=treatment[i],nrpoints=0,colramp=colorRampPalette(viridis(11)))
	fm1 <- lm(treatment ~ ns(control, df = 4),data=data)
	nD <- data.frame(control = data$control)
	lines(data$control, p1<-predict(fm1, nD),col="red")
	data$r<-residuals(fm1)
	index<-abs(data$r)>2
	points(data$treatment[index]~data$control[index],pch=20,col="red",cex=.25)
	res[,i]<-data$r
	x<-tapply(data$r,data$Gene,mean)
	u<-mean(data$r)
	s<-sd(data$r)
	sgrnas.n<-snakemake@config$sgrnas$n
	z<-(x-u)/(s/sqrt(sgrnas.n))
	p<-2*pnorm(-abs(z))
	fdr<-p.adjust(p)
	gene<-data.frame(Gene=names(z),z=z,p=p,fdr=fdr)
	gene<-gene[order(gene$fdr),]
	plot(-log10(gene$fdr)~gene$z,zlab="Z score",ylab="-log10(p)",pch=20,col="dark grey")
	text(y=-log10(gene$fdr)[1:10],x=gene$z[1:10],labels=gene$Gene[1:10],cex=.75,font=3)
	gene<-gene[order(gene$Gene),]
	zm[,i]=gene$z
	fdrm[,i]=gene$p
}
dev.off()

rownames(zm)=gene$Gene
colnames(zm)=treatment
write.table(zm,file=snakemake@output[["zscores"]],sep="\t")

finaldata<-data.frame(Gene=gene$Gene,p=apply(fdrm,1,function(x){sumlog(x)$p}),z=rowMeans(zm))
finaldata$fdr=p.adjust(finaldata$p)
finaldata<-finaldata[order(finaldata$fdr,decreasing=FALSE),]
write.table(finaldata,file=snakemake@output[["metazscore"]],sep="\t")


pdf(snakemake@output[["zscoreheatmap"]],height=8,width=3,pointsize=8)
zm<-zm[finaldata$Gene[finaldata$fdr<.05],]
zm<-zm[order(rowSums(zm),decreasing=FALSE),]
zm<-zm[1:min(snakemake@config[["heatmapCount"]],nrow(zm)),]

# Invert z-score values
zm<-(zm * -1)

pal<-colorRampPalette(rev(brewer.pal(n = 11, name = "RdYlBu")[-4]))
newnames <- lapply(
  rownames(zm),
  function(x) bquote(italic(.(x))))
pheatmap(zm,col=pal(9),scale="none",cluster_cols = FALSE,cluster_rows = FALSE,cex=.75,breaks=seq(snakemake@config[["heatmapMin"]],snakemake@config[["heatmapMax"]],length.out=9),cellwidth=8,cellheight=8,labels_row = as.expression(newnames))
dev.off()

# Print out warnings
summary(warnings())
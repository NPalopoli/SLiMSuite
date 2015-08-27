######################################################
### COMPOSITE IMAGE SCRIPT FOR PPI NETWORKS ~~~~~~ ###
### AUTHOR: Dr Richard Edwards 2008 ~~~~~~~~~~~~~~ ###
### CONTACT: r.edwards@soton.ac.uk ~~~~~~~~~~~~~~~ ###
######################################################

############# ::: GENERAL SETUP ::: ##################

## ~ Read commandline arguments ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
args <- commandArgs(TRUE)
rtype = args[1]
basefile = args[2]

############# ::: CREATE FUNCTIONS ::: ###############

## ~ Calculate X and Y coordinates for network nodes, given angle ~~~~ ##
getSpokeXY = function(i,inum,offset=0.1,start_ang=0){
	### Calculate X and Y from Angle ###
	spangle = 360 / inum
	A1 = spangle * (i-1) + start_ang
	if(A1 > 360){ A1 = A1 - 360 }
	A = A1
	while (A >= 90){ A = A-90 }
	A = (A / 360) * (2 * pi)	# Convert to rads
	o = sin(A) * (1-offset)
	a = cos(A) * (1-offset)
	if (A1 < 90){
		x = o
		y = a
	}
	if (A1 >= 90 & A1 < 180){
		x = a
		y = -o
	}
	if (A1 >= 180 & A1 < 270){
		x = -o
		y = -a
	}
	if (A1 >= 270){
		x = -a
		y = o
	}
	c(x,y)
}

## ~ Plot partial PPI network with given coordinates ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
networkPlot = function(infile,h=0.1,w=0.25,fex=1){
	## Read file and Setup ##
	## PPI File has spokes as columns and corresponding rows mark presence/absence of interaction and line thickness ##
	## Following rows for interactions are three more rows: Xcoord, Ycoord, Colour code
	ppi = read.table(infile,sep="\t",header=TRUE,stringsAsFactors=FALSE,check.names=FALSE)
	spokenum = length(colnames(ppi))
    # Setup scale of plot
    xrow = spokenum + 1
    yrow = xrow + 1
    if( max(h,max(ppi[xrow,])) < (max(w,max(ppi[yrow,])) / 2)){
        temp = ppi[yrow,]
        ppi[yrow,] = ppi[xrow,]
        ppi[xrow,] = temp
    }
    xmax = max(h,max(ppi[xrow,]))
    ymax = max(w,max(ppi[yrow,]))
	scale = min(1,10/spokenum)     # Designed for 2 x 2
	# Smallest scale = 0.5 in a 5.0 x 5.0 (h=0.1,w=0.15)
	minh = 0.1 * 0.1 * ymax
	minw = 0.25 * 0.1 * xmax
	h = h * scale * ymax / 2.0
	h = max(h, minh)
	w = w * scale * xmax / 2.0
	w = max(w, minw)
	minscale = 0.6
	scale = max(minscale, scale)
	#scale = max(minscale, scale*ymax)
	## Empty Plot ##
	old_mar = par()$mar
	par(mar=c(0.2,0.2,0.2,0.2))
	if(spokenum == 1){ w = 0.1; h = 0.1; xmax = 1.0; ymax = 1.0 }
	if(ymax < (xmax / 2)){  plot(c(-w,xmax+w),c(-h-0.5*ymax,1.5*ymax+h),type="n",axes=FALSE,ann=FALSE) }
	else{ plot(c(-w,xmax+w),c(-h,ymax+h),type="n",axes=FALSE,ann=FALSE) }
	## Draw connections ##
	for (i in 1:spokenum){
		x = ppi[xrow,i]
		y = ppi[yrow,i]
		### Draw connections ###
		for (j in 1:spokenum){
			if (ppi[i,j] == 0){ next }
			lines(c(x,ppi[xrow,j]),c(y,ppi[yrow,j]),lwd=2*ppi[i,j])
		}
	}
	### Draw Spokes ###
	start_ang = 0  #360 / (2 * spokenum)
	for (i in 1:spokenum){
		x = ppi[xrow,i]
		y = ppi[yrow,i]
		if (length(rownames(ppi)) > spokenum+2){
			rect(x-w,y-h,x+w,y+h,xpd=TRUE,col=ppcol[ppi[spokenum+3,i]+1],lwd=2)  # ppcol = black + soton$col
			if (ppi[spokenum+3,i] == 1){
				text(x,y,colnames(ppi)[i],adj=c(0.5,0.5),xpd=TRUE,font=2,cex=fex*1.2*scale,col=soton$col[12])
			}else{
				text(x,y,colnames(ppi)[i],adj=c(0.5,0.5),xpd=TRUE,font=2,cex=fex*1.2*scale)	#,col=soton$col[17])
			}
		}else{
			rect(x-w,y-h,x+w,y+h,xpd=TRUE,col="#979E45",lwd=2)
			text(x,y,colnames(ppi)[i],adj=c(0.5,0.5),xpd=TRUE,font=2,cex=fex*1.2*scale,col=soton$col[1])
		}
	}
	par(mar=old_mar)
}

## ~ Plot partial PPI network ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
networkRing = function(infile,h=0.1,w=0.15,fex=1){
	#x#infile = paste(basefile,".ppi.tdt",sep="")
	## Read file and Setup ##
	ppi = read.table(infile,sep="\t",header=TRUE,stringsAsFactors=FALSE,check.names=FALSE)
	spokenum = length(colnames(ppi))
	scale = min(1,10/spokenum)
	h = h * scale
	w = w * scale
	## Empty Plot ##
	old_mar = par()$mar
	par(mar=c(0.2,0.2,0.2,0.2))
	plot(c(-1,1),c(-1,1),type="n",axes=FALSE,ann=FALSE)
	## Draw connections ##
	for (i in 1:spokenum){
		coord = getSpokeXY(i,spokenum,w)
		x = coord[1]
		y = coord[2]
		### Draw connections ###
		for (j in 1:spokenum){
			if (ppi[i,j] == 0){ next }
			coord2 = getSpokeXY(j,spokenum,w)
			lines(c(x,coord2[1]),c(y,coord2[2]),lwd=2)
		}
	}
	### Draw Spokes ###
	start_ang = 0  #360 / (2 * spokenum)
	for (i in 1:spokenum){
		coord = getSpokeXY(i,spokenum,w,start_ang)
		x = coord[1]
		y = coord[2]
		if (length(rownames(ppi)) > spokenum){
			rect(x-w,y-h,x+w,y+h,xpd=TRUE,col=ppcol[ppi[spokenum+1,i]+1],lwd=2)
			if (ppi[spokenum+1,i] == 0){
				text(x,y,colnames(ppi)[i],adj=c(0.5,0.5),xpd=TRUE,font=2,cex=fex*1.2*scale,col=soton$col[12])
			}else{
				text(x,y,colnames(ppi)[i],adj=c(0.5,0.5),xpd=TRUE,font=2,cex=fex*1.2*scale)	#,col=soton$col[17])
			}
		}else{
			rect(x-w,y-h,x+w,y+h,xpd=TRUE,col="#979E45",lwd=2)
			text(x,y,colnames(ppi)[i],adj=c(0.5,0.5),xpd=TRUE,font=2,cex=fex*1.2*scale,col=soton$col[1])
		}
	}
	par(mar=old_mar)
}

## ~ Plot partial PPI network ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
nestedNetworkRing = function(infile,h=0.09,w=0.2,fex=1){
	#infile = paste(basefile,".nested.tdt",sep="")
	#h=0.09
	#w=0.2
	## Read file and Setup ##
	ppi = read.table(infile,sep="\t",header=TRUE,stringsAsFactors=FALSE,check.names=FALSE)
	(hubnum = length(colnames(ppi)) - 1)
	(spokenum = length(ppi[,1]))
	iscale = min(1,20/spokenum)		# Size of Outer Ring
	jscale = min(1,10/hubnum)		# Size of Inner Ring
	ih = h * iscale
	iw = w * iscale
	jh = h * jscale
	jw = w * jscale
	## Empty Plot ##
	old_mar = par()$mar
	par(mar=c(0.2,0.2,0.2,0.2))
	plot(c(-2,2),c(-2,2),type="n",axes=FALSE,ann=FALSE)
	## Draw connections ##
	for (i in 1:spokenum){
		coord = getSpokeXY(i,spokenum,iw)
		x = coord[1] * 2
		y = coord[2] * 2
		### Draw connections ###
		for (j in 1:hubnum){
			if (ppi[i,j+1] == 0){ next }
			coord2 = getSpokeXY(j,hubnum,jw)
			lines(c(x,coord2[1]),c(y,coord2[2]),lwd=2)
		}
	}
	### Draw Hubs ###
	for (j in 1:hubnum){
		coord = getSpokeXY(j,hubnum,jw)
		x = coord[1]
		y = coord[2]
		rcol = soton$col[5]
		tcol = soton$col[1]
		hubname = colnames(ppi)[j+1]
		if(substr(colnames(ppi)[j+1],1,1) == "d"){
      		rcol = soton$col[3]
  	 	    tcol = soton$col[1]
  	 	    hubname = substr(hubname,2,nchar(hubname))
  	 	}
		if(substr(colnames(ppi)[j+1],1,2) == "rs"){ rcol = soton$col[10] }
		if(substr(colnames(ppi)[j+1],1,2) == "ru"){ rcol = soton$col[11] }
		rect(x-jw,y-jh,x+jw,y+jh,xpd=TRUE,col=rcol,lwd=2)
		text(x,y,hubname,adj=c(0.5,0.5),xpd=TRUE,font=2,cex=fex*1.2*jscale,col=tcol)
	}
	### Draw Spokes ###
	for (i in 1:spokenum){
		coord = getSpokeXY(i,spokenum,iw)
		x = coord[1] * 2
		y = coord[2] * 2
		rect(x-iw,y-ih,x+iw,y+ih,xpd=TRUE,col=soton$col[1],lwd=2)
		text(x,y,ppi[i,1],adj=c(0.5,0.5),xpd=TRUE,font=2,cex=fex*1.2*iscale,col=soton$col[5])
	}
	par(mar=old_mar)
}


## ~ Generation of tree plot from data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
makeTree = function(infile,treetitle="",fex=1){
	### ~ SETUP ~ ###
	tree = read.csv(infile)
	ynum = length(tree$xpos)
	x = 1 / (2*max(tree$xpos))
	y = 1 / (ynum+1)
	tree$fcol = soton$col[1]	#"black"

	### ~ Setup Plot ~ ###
	#!# pngwidth = 1600
	#!# if (length(args) > 3) { pngwidth = as.integer(args[4]); }
	#!# png(filename = outfile, width = pngwidth, height = (ynum+2)*50, units = "px", pointsize=25)
	old_mar = par()$mar
	par(mar=c(0.2,0.2,10,0.2))
	plot(0:1,0:1,type="n",axes=FALSE,ann=FALSE,mar=c(0,1,4,1))
	if (length(treetitle) > 2) { title(main=treetitle); }

	### ~ Draw Tree ~ ###
	for (i in 1:ynum){
		data = tree[i,]
		lines(c(data$xpos*x,data$ancx*x),c(1-data$ypos*y,1-data$ypos*y),col=data$fcol,lwd=2)
		lines(c(data$ancx*x,data$ancx*x),c(1-data$ypos*y,1-data$ancy*y),col=data$fcol,lwd=2)
	}
	### ~ Add Text ~ ###
	for (i in 1:ynum){
		data = tree[i,]
		if (data$nodenum <= ((ynum+1) / 2)){
			text((data$xpos)*x+0.01,1-data$ypos*y,data$name,adj=c(0,0.5),cex=fex*min(1.2,38/ynum),col=data$fcol)
		}else{
			text((data$xpos)*x-0.01,1+(0.45/ynum)-data$ypos*y,data$boot,adj=c(0.8,0),cex=fex*min(1,38/ynum),font=3,col=soton$col[5])
		}
	}
	### ~ Add scale ~ ###
	lines(c(0,0.1*x),c(0,0),col=soton$col[7],lwd=2)
	lines(c(0,0),c(0,-0.005),col=soton$col[7],lwd=2)
	lines(c(0.1*x,0.1*x),c(0,-0.005),col=soton$col[7],lwd=2)
	text(0,-0.01,"0",adj=c(0.5,1),cex=fex*min(0.8,38/ynum),col=soton$col[7],xpd=NA)
	text(0.1*x,-0.01,"0.1",adj=c(0.5,1),cex=fex*min(0.8,38/ynum),col=soton$col[7],xpd=NA)
	par(mar=old_mar)
	#!# dev.off()
}

## ~ Generation of heatmap from data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
heatMap = function(infile,fex=1){
	## Read file and Setup ##
	gb = 255 - 144
	dist = read.table(infile,sep="\t",header=TRUE,stringsAsFactors=FALSE,check.names=FALSE)
	names = dist[,1]
	n = 1 / length(names)
	## Empty Plot ##
	old_mar = par()$mar
	par(mar=c(2,0.2,8,0.2))
	plot(0:1,0:1,type="n",axes=FALSE,ann=FALSE)
	## Squares ##
	for (i in 1:length(names)){
		#text(-0.01,1-(i-0.5)*n,dist[i,1],adj=c(1,0.5),xpd=TRUE,font=1,family="sans",cex=0.7)
		text((i-0.5)*n,1.01,dist[i,1],adj=c(0,0.5),xpd=TRUE,font=1,family="sans",cex=fex,srt=90)
		for (j in 1:length(names)){
			D = 1 - dist[i,j+1]
			C = (255 - (D * gb)) / 255
			rect((i-1)*n,1-(j-1)*n,i*n,1-j*n,col=rgb(1-D,C,C),xpd=TRUE,lwd=2)
			text((i-0.5)*n,1-(j-0.5)*n,as.integer(100*(D+0.005)),adj=c(0.5,0.5),xpd=TRUE,cex=fex*min(1,12/length(names)))
		}
	}
	par(mar=old_mar)
}


############# ::: MAIN RUN - GRAPHICS PLOT ::: ###################

## ~~~~~~~~~~~~~ PPI MULTIPANEL PLOT ~~~~~~~~~~~~~~~~ ##
multiPanelPPI = function(basefile){
	## ~ Setup multipanel plot ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
    ppi = read.table(paste(basefile,".ppi.tdt",sep=""),sep="\t",header=TRUE,stringsAsFactors=FALSE,check.names=FALSE)
	spokenum = length(colnames(ppi))
    if (spokenum > 40){
        pwidth = min(spokenum*20,1600) 
        pheight = min(spokenum*30,2400)
    }
    else{ 
        pwidth = min(spokenum*30,800)
        pheight = min(spokenum*45,1200)
    }
    pwidth = max(pwidth,600)
    pheight = max(pheight,900)
	pngfile=paste(basefile,".png",sep="")
    #CairoPNG(filename=pngfile, width=pwidth, height=pheight, pointsize=12)
	png(filename=paste(basefile,".png",sep=""), width=pwidth, height=pheight, units = "px", pointsize=12)
	panels = c(1,1,1,1,1,2,3,3,3,3)
	layout(matrix(panels,byrow=TRUE,nrow=2))
	#layout.show(11)
	## ~ Plot PPI network for motif-containing spokes ~~~~~~~~~~~~~~~~~~~~ ##
	networkRing(paste(basefile,".ppi.tdt",sep=""),fex=3)
	## ~ Plot tree for motif-containing spokes (based on GABLAM) ~~~~~~~~~ ##
	makeTree(paste(basefile,".tree.csv",sep=""),fex=2)
	## ~ Make Heatmap (based on GABLAM) ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
	heatMap(paste(basefile,".heatmap.tdt",sep=""),fex=2)
	dev.off()
}
if (rtype == "interactome"){ multiPanelPPI(basefile) }

## ~~~~~~~~~~~~~ Nested PPI Plot ~~~~~~~~~~~~~~~~~~~~ ##
nestedPNG = function(basefile){
	pngfile=paste(basefile,".png",sep="")
    #CairoPNG(filename=pngfile, width=2400, height=2400, pointsize=12)
	png(filename=paste(basefile,".png",sep=""), width=2400, height=2400, units = "px", pointsize=12)
	nestedNetworkRing(paste(basefile,".nested.tdt",sep=""),fex=3)
	dev.off()
}
if (rtype == "nested"){ nestedPNG(basefile) }


## ~~~~~~~~~~~~~ Pure PPI Plot ~~~~~~~~~~~~~~~~~~~~ ##
purePPIPNG = function(basefile){
	pngfile=paste(basefile,".png",sep="")
    #CairoPNG(filename=pngfile, width=2400, height=2400, pointsize=12)
	png(filename=paste(basefile,".png",sep=""), width=2400, height=2400, units = "px", pointsize=12)
	networkPlot(paste(basefile,".ppi.tdt",sep=""),fex=3)
	dev.off()
}
if (rtype == "pureppi"){ purePPIPNG(basefile) }


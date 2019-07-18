#Load and run the model ONCE on page startup
options(error = recover)
options(shiny.maxRequestSize=30*1024^2) 
options(shiny.trace=F)
options(shiny.fullstacktrace=F)
library(shiny)
library(ggplot2)
library(plyr)
library(dplyr)
library(data.table)
library(gridExtra)
library(grid)
library(stringr)

my_theme <-  theme_bw()  +  theme(panel.border = element_blank()) +   theme(axis.line = element_line(color = 'black')) 
panel_theme <- theme_bw(base_size = 10, base_family = "Helvetica")  +  theme(legend.position = "none")


trim <- function (x) gsub("^\\s+|\\s+$", "", x)

pctt <- function(dataf)
{
  e <- ecdf(dataf$val)
  dataf$pct <- round(e(dataf$val),2)
  return (dataf)   
}

get_default_folder = function(x){return (switch (x, 'CaseCol'='Filepart 1','TypeCol'='Folder2', 'SnapCol'='Filename'))} #Snap defaults to filename, usually unique cell IDs per filename

get_default_channel = function(x){return (switch(x,'NormChan' = 'Ch3', 'ColourChan' = 'Ch3', 'YChan' = 'Ch2', 'XChan' = 'Ch4' ,''))}
#get_default_label = function(x){return (switch(x,'Ch2' = 'Porin', 'Ch1' = 'Complex IV', 'Ch3' = 'Complex I' ,x))}
get_default_label = function(x){return (switch(x,'Ch2' = 'MTCO1', 'Ch1' = 'Laminin', 'Ch3' = 'Porin', 'Ch4' = 'NDUFB8' ,x))}
get_default_bg_ordered = function(x){return (switch(x,'Complex I' = T, 'NDUFB8' = T,F ))}
get_default_bg_remove = function(x){return (switch(x,'Area' = F, T ))}
get_default_norm = function(x){return (switch(x,'NDUFB8'=T,'COX-I' = T, 'COX'=T, 'Complex I' = T, 'Complex IV' = T,'MTCO1' = T,F ))}
get_default_use = function(x){return (switch(x,'Complex I' = T, 'Complex IV' = T,'Porin' = T,'Area'=T,'MTCO1'=T,'NDUFB8'=T,F ))}

get_default_cuts = function(x){return (switch(x,'Porin' = '-3,-2,2,3',  '-6,-4.5,-3' ))}
get_default_cut_labels = function(x){return (switch(x,'Porin' = 'Very low,Low,Norm,High,Very high', 'Neg,Int(-),Int(+),Pos' ))}

get_default_controls <- function(x){return (c('B068','B0014','M0734-11','M0955-10','M0676-14','M0682-14','M0684-14','M0678-14','C04_B','C05_B','C09_B','C10_B','C12_B','C04_00baseline','C05_00baseline','C09_00baseline','C10_00baseline','C12_00baseline','535','533','549','551','922'))}

cont_cols <- c('CaseCol','SnapCol','TypeCol')



#Transparency for the dots.
alp <- 0.6

#Colours for the colour variable thing 
cbPalette <- c("#2306e0", "#7d6afb", "#bbbbbb", "#f97706","#de2721")

#cbPalette <- c("#2b0af9", "#a496fd", "#fee4b9", "#f97b0a","#de2d26")
names(cbPalette) <- c('Very low','Low','Norm','High','Very high')









plot_hist <- function(data, x_val, title){
  if (x_val != 'val_') {
      v_fill <- 'pc'
      v_color <- 'pc'
      data$title <- paste(data$pc, data$caseno)
      p <- 	ggplot(data, aes_string(x=x_val,color=v_color,fill=v_fill) ) +  geom_bar(aes(y = (..count..)/tapply(..count..,..PANEL..,sum)[..PANEL..]*100),stat='bin') + ylab('Percentage')+xlab(title)+my_theme
      p <- p + facet_wrap(~title)
    	return (p)
  }
}

plot_hist_pooled <- function(data, x_val, title){
  if (x_val != 'val_') {
	v_fill <- 'pc'
	v_color <- 'pc'

	p <- 	ggplot(data, aes_string(x=x_val,color=v_color,fill=v_fill) ) +  geom_bar(aes(y = (..count..)/tapply(..count..,..PANEL..,sum)[..PANEL..]*100),stat='bin') + ylab('Percentage')+xlab(title)+my_theme


  	return (p)
  }
}

do_graph <- function(caseno, data, x_range, y_range, labs){
  
  this_data <- data[data$caseno == caseno,];
  
  pal <- c("#2b0af9", "#a496fd", "#fee4b9", "#fcc86e","#2b0af9", "#a496fd", "#fee4b9", "#fcc86e") #Make this long enough to deal with any number of categories

  top_graphs <- lapply(labs$ids, function(id) {
    if (is.na(labs$ch[id])) {return(NULL)}
    ch <- labs$ch[[id]]
    if (is.na(ch)) {return(NULL)}
    var_name <- labs$var_name[id]
    label <- labs$label[[id]]
    this_pal <- pal[1:length(labs$cut_labels[[id]])]
    names(this_pal) <- labs$cut_labels[[id]] 
    
    cuts <- labs$cuts[[id]]
    
    cut_labels <- labs$cut_labels[[id]]
    cat <- paste('cat',var_name, sep='_')
    
    graph <- switch (labs$graph_type[[id]],
                     
       'bc' = ggplot(this_data, aes_string(paste('factor(',cat ,')'), fill=cat)) + 
        geom_bar(aes(y = (..count..)/sum(..count..)*100),stat = "count")+ 
        ylab("% muscle fibres") + xlab(label)  +
        scale_fill_manual(values=this_pal) + 
        panel_theme +
        xlim(cut_labels)  +
        ylim(0,100),
       'h' =
       ggplot(this_data, aes_string(x=paste('z_',var_name, sep=''))) + 
        geom_bar(aes(y = (..count..)/sum(..count..)*100),stat = "bin") + 
        ylab("% muscle fibres") + xlab(label) + panel_theme +geom_vline(xintercept=0,color="#2b0af9")+
        geom_vline(xintercept=c(-3,3),color="#fcc86e"),
       'x' = NULL)
    return (graph)  
  })
  top_graphs <- top_graphs[!sapply(top_graphs, is.null)]


  x_z <- paste('z_',labs$var_name['X'], sep='')
  y_z <- paste('z_',labs$var_name['Y'], sep='')
  a_z <- paste('z_',labs$var_name['Area'], sep='')
  c_z <- paste('z_',labs$var_name['Colour'], sep='')
  
  c_cat <- paste('cat_',labs$var_name['Colour'], sep='')


  #If any of the values will be off the limits, draw them AT THE BORDER!
  this_data[,x_z] <- sapply(this_data[,x_z], function(x) max(x,x_range[1]))
  this_data[,y_z] <- sapply(this_data[,y_z], function(x) max(x,y_range[1]))
  
  #Plot statement. The first couple of lines do the main graph and the points
  if (is.na(labs$ch['Area'])) {
    g <- ggplot(this_data, aes_string(x_z, y_z)) +  
      geom_point(aes_string(color=c_cat ), size=2,alpha=alp) + #Coloured circles
      geom_point(shape=1, size=2 ,color='#444444', alpha=0.3) 
  } else {
    g <- ggplot(this_data, aes_string(x_z,y_z)) +  
      geom_point(aes_string(color=c_cat,size=a_z), alpha=alp) + #Coloured circles
      geom_point(aes_string(size=a_z),shape=1, color='#444444', alpha=0.3) 
  }
  
  g <- g + #Border of coloured circles. I made it not quite black and also more transparent
    guides(size=FALSE)    +
    theme_bw(base_size = 10, base_family = "Helvetica") + #Get rid of the grey background, set the font and font size
    #Green dashed lines
    geom_vline(xintercept=0, colour="#fcc86e", linetype="dashed") +
    geom_hline(yintercept=0, colour="#fcc86e", linetype="dashed") 
  
  x_cuts <- labs$cuts[['X']]
  y_cuts <- labs$cuts[['Y']]
  
  g <- g + sapply(x_cuts, function(x) geom_vline(xintercept=x, colour="#636363", linetype="dotted")) +
    sapply(y_cuts, function(x) geom_hline(yintercept=x, colour="#636363", linetype="dotted"))
  
  #coloured squares for lowest and highest
  g <- g +     
    geom_rect(size=0.8,xmin = x_cuts[length(x_cuts)], ymin = y_cuts[length(y_cuts)], xmax = Inf, ymax = Inf,  color='#fcc86e', fill='#FFFFFF', alpha = 0) +
    geom_rect(size=0.8,xmin = x_cuts[1], ymin = y_cuts[1], xmax = -Inf, ymax = -Inf,  color='#2b0af9', fill='#FFFFFF', alpha = 0) 
  
  #Black squares for intermediate. If there are different numbers of cuts in X and Y I don't know how to do the black boxes. So we'll just do them if the cuts count is the same
  if (length(x_cuts) == length(y_cuts)) {
    g <- g +  sapply(1:(length(x_cuts)-1), function(i) 
      geom_rect(size=0.8,xmin = x_cuts[i], ymin = y_cuts[i], xmax = x_cuts[i+1], ymax = y_cuts[i+1],  color='#000000', fill='#FFFFFF', alpha = 0) 
    )
  }
  
  g <- g + 
    scale_fill_manual(name = labs$label[['Colour']], values=cbPalette) + 
    scale_colour_manual(name = labs$label[['Colour']],values=cbPalette) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())  + 
    #coord_fixed makes sure that the x and y scales are equal. It doesn't make them square if the ranges are different, it just means 1 sd in both y and x are the same width
    coord_fixed() + 
    #Set which tick marks to show on the scales
    scale_x_continuous(limits=x_range, breaks=c(-25, -20, -15, -10, subset(x_cuts, round(x_cuts)==x_cuts),0)) +
    scale_y_continuous(limits=y_range, breaks=c(-25, -20, -15, -10, subset(y_cuts, round(y_cuts)==y_cuts),0)) +
    xlab(paste(labs$label[['X']], ' (standard deviations)')) +	ylab(paste(labs$label[['Y']], ' (standard deviations)')) +theme(legend.position="bottom",legend.key = element_rect(colour = NA,size=NA))
  
  g_title <- textGrob(caseno, gp=gpar(fontsize=13,font=2))

    topgrob <- arrangeGrob(grobs=top_graphs, ncol=length(top_graphs))
  
  page1 <-arrangeGrob(g_title,topgrob,g,heights=c(.04, .21,.75),ncol=1)


  
    ##This function returns a list containing the entire page plus a separate grob of the main panel
  x <- list()
  x$main_panel <- g
  x$page <- page1
  
  return (x)
}


save_case <- function(all_data, fs, caseno, xrange, yrange, labs){
	path <- paste0('pdf/',caseno, ".pdf")
	x <- do_graph(caseno, all_data, xrange, yrange, labs)
	pdf(file=path,width=10,height=10*1.414,onefile=FALSE);
	print(grid.arrange(x$page))
	dev.off()	
	fs <- c(fs, path)

	path <- paste0('main/', caseno, ".pdf")
	pdf(file=path,width=5,height=5.5,onefile=FALSE);
	print(x$main_panel)
	dev.off()	
	fs <- c(fs, path)

	path <- paste0('tif/',caseno, ".tif")
	tiff(path, width=600, height=600*1.414)
	print(grid.arrange(x$page))
	dev.off()	
	fs <- c(fs, path)
	
	#This function adds the newly generated files to the variable passed back with the new images in it
	#A better structure would be a list which contains the images and ALSO the files, but I know I only use it once, so sod it.
	x$fs <- fs
	return (x)
}

shinyServer(function(input, output, session) {

  mess <- reactiveValues(text = list())

    output$prep_err <- renderText({
      print('Updating prep error text')
      if (is.null(mess$text)) {return(NULL)}
    return (paste(mess$text, collapse='\n'))
  })
  
  clean_chan_name <- function(x){
    if (is.null(x) | x =='') {return ('')}
    #Return a CLEANED version of the channel name, without spaces for instance. 
    #The input to the function is the channel code from the data file, e.g. Ch1
    s <- (gsub('[^[:alnum:]]','.',(input[[paste(x, '_label',sep='')]])))
	return (s)
	}
  
  do_models <- function(rdata, all_data, ch, use, norm, norm_chan, cuts, cut_labels){
    #use indicates which channels 
    #norm indicates if this channel should be normalised to the norm_chan
    #norm_chan is the normalisation channel, usually porin. Note, I may upgrade this and have the norm_chan specified per channel, if we can normalise to different things.
    
    ##This should fix any NaNs, but note, we should maybe print a message saying how many bad lines there are.
    all_data <- all_data[complete.cases(all_data), ]
	
	dt = all_data[(all_data$id==1)&(all_data$snap=="B068 OXPHOS"),]
	print(dt)
    
    for (c in 1:length(ch)){
      if (use[c]==T){
        chan <- ch[c]
        col_val <- paste('val_',clean_chan_name(chan),sep='')
        #If we normalise it to the norm channel then do so, if not, just do the mean and sd of the rdata and then get z score
        if (norm[c]==T) {
          model <- lm(paste(col_val, '~', 'val_',clean_chan_name(norm_chan),sep=''), data=rdata)
          pred <- predict(model, all_data, se.fit=TRUE,  interval = "prediction")$fit
          all_data[,paste('z_',clean_chan_name(chan),sep='')] <- (all_data[,col_val] - pred[,'fit'])/((pred[,'upr'] - pred[,'lwr'])/(2*1.96))
        } else {
          u <- mean(rdata[,col_val])
          s <- sd(rdata[,col_val])
          all_data[,paste('z_',clean_chan_name(chan),sep='')] <- (all_data[,col_val] - u)/s
        }
        
        #The CATEGORIES are conceptually a little tricky to work out. Do they apply to the CHANNEL or to the X/Y/etc???
        #I'll attach them to the channel. 
        all_data[,paste('cat_',clean_chan_name(chan),sep='')] <- cut(all_data[,paste('z_',clean_chan_name(chan),sep='')], cuts[[c]], cut_labels[[c]])
      }
    }      
    
    return (all_data)
  }
  
	shinyjs::disable("download_all") #This is so that the download button only is available once the data has been prepared.

	#r_labs is a reactive variable that stores the labels attached to the various elements of the graphs
  r_labs <- reactive({
    l <- list()
    l$ids <- c('X','Y','Colour','Area')
    l$ch <- sapply(l$ids, function(x) input[[paste(x, 'Chan',sep='')]])
    l$ch <- l$ch[!sapply(l$ch, function(x) {is.null(x) | x==''})] #Remove any null channels, as we don't need channels that are not processed. e.g. area is optional
    l$label <- lapply(l$ch, function(x) input[[paste(x, 'label',sep='_')]])
    l$var_name <-lapply(l$ch, function(x) clean_chan_name(x))
    l$graph_type <- sapply(l$ids, function(x) input[[paste(x, 'Graph',sep='')]])
    
    l$cut_labels <- lapply(l$ch, function (x) {   strsplit(input[[paste(x, 'cut_labels',sep='_')]],',')[[1]]	}) #are they to be normalised to the norm channel?
    l$cuts <- lapply(l$ch, function (x) {  as.numeric(strsplit(input[[paste(x, 'cuts',sep='_')]],',')[[1]])	}) #are they to be normalised to the norm channel?
    
    #If they are updated, we need to update the list of options for the graphs.
    return(l)
  })	

	
r_dataInput <- reactive({

   inFile <- input$file1
    if (is.null(inFile))
		return(NULL)
		
	withProgress({
	

	incProgress(1/15, detail = "Reading csv file")
	
	d <- read.csv(inFile$datapath, header = T,stringsAsFactors=F)

	incProgress(1/15, detail = "Renaming columns")
 
 
	d <- plyr::rename(d, c(
	  "Value"="val",
	  "ID"="id",
	  "Channel"="channel" ,
	  	  "case"="caseno",
			"Case"='caseno',
			'Subject'='caseno',
			'subject'='caseno',
			'Filename.'='Filename',
			'Filename..'='Filename'

	  ))

		#For some reason, fprintf is putting a SPACE or other character after the filename at the end of the first line. 
		#We need to be able to deal with that in the filename
	  
	d$grp <- 1

	
 	cols <- (names(d))
	#Remove the Channel and Value columns, they have fixed meanings
	cols <- cols [! cols %in% c('channel','val','id')]

	#Split the filename by the separator, and if there are 
	if (input$separator != ''){
		if ('Filename' %in% cols)
		{
			incProgress(1/15, detail = "Finding unique names")
			#For efficiency, get the unique list of filenames and work from that
			unique_filenames <- as.data.frame(unique(d$Filename));
			names(unique_filenames) = 'Filename'
			incProgress(1/15, detail = "Splitting filenames")
			vv <- as.data.frame(t(as.data.frame(apply(unique_filenames, 1, function(y) {
				x <- strsplit(y['Filename'],input$separator,fixed=T)[[1]]
				#we don't know how many separate parts of the filenames there are, but assume a maximum of 10, and we can trim it down later
				return (c(x, vector(length=10-length(x),mode='character')))
		  }
			))))
			names(vv) <- paste('Filepart ', seq(1,ncol(vv)), '',sep='')
			vv <- vv[, colSums(vv != "") != 0]
			vv[] <- lapply(vv, as.character) #without this they are factors!
		unique_filenames <- cbind(vv,unique_filenames)
			incProgress(1/15, detail = "Merging")
		d <- merge(unique_filenames,d, by='Filename')
	
			} }
	
	#update the cols again, as we have added some perhaps.
	cols <- names(d)
	#Remove the Channel and Value columns, they have fixed meanings
	cols <- cols [! cols %in% c('channel','val','id')]

	incProgress(1/15, detail = "Updating user interface")
	
	if ('caseno' %in% cols) {
		find_case = FALSE
		#Need to update the default_cols with this one! Actually, we don't, if the caseno column exists it just uses that one, rather than renaming

	} else {find_case = TRUE	}
	
	default_cols <- lapply(cont_cols, get_default_folder)
	names(default_cols) <- cont_cols
	#If we can find a column with M numbers in it, use that as the cases. But only if we don't already have a column called caseno
	#A column with NPC or OXPHOS will be the type
	top10 <- d[1:10,]
	#browser()
	for (i in 1:ncol(top10)){
		v <- unique(top10[,i])
	    #An n/a value in the top row causes the website to break, so ignore it.
			if (!is.na(v[1])){
		  if (tolower(substr(v[1],1,6))=='oxphos' || tolower(substr(v[1],1,3))=='npc'){default_cols$TypeCol = names(top10)[i]}	
		  if (find_case && substr(top10[1,i],1,1)=='M'){default_cols$CaseCol = names(top10)[i]}	
		}		
	}
	
	#Update the available columns
	sapply(cont_cols, function (x) updateSelectInput(session, x, choices = cols,  selected = default_cols[[x]]))
	incProgress(1/15)
  

	
	
	},
	message = 'Reading the input file...', value = 0)
		

	 

	return(d)
})

r_dataInput_renamed <- reactive({
	data <- r_dataInput()
	if (is.null(data)){return(NULL)}
			
	withProgress(
	{
	 

	 
	if (input$CaseCol != 'caseno') {
		if (input$CaseCol != '')
		{	
			data$caseno <- as.factor(data[,input$CaseCol])
			#names(data)[names(data)==input$CaseCol] <- 'caseno'
		} else {
			data$caseno <- as.factor('')
		}
	}


	#Rename snap if it is a real column, if it's not there'll be a dummy one added already
 	#Add a blank dummy column if we don't have a snap column specified
	#2016.04.06 Actually, DON'T. If the same col is used for snap and something else we get a weird error with renaming.
	#To save this, we'll COPY snap, to another place.
	#Note, for things like SNAP, a factor would be FAR more memory efficient than strings.
	#Should maybe revisit strings as factors at some point
	if (input$SnapCol == '') { 
		data$snap <- 1
	} else {
		data$snap <- as.factor(data[,input$SnapCol])
#		names(data)[names(data)==input$SnapCol] <- 'snap'
	}

#	if (!('typ' %in% colnames(data))) {return(NULL)} typ does NOT have to be specified, but if it isn't, no background correction will be done
	if (!('caseno' %in% colnames(data))) {return(NULL)}
	if (!('snap' %in% colnames(data))) {return(NULL)}

	
	##common spelling mistakes
	if (input$TypeCol != ''){
		#Typ is always set, not copied.
		data$typ <- data[,input$TypeCol]
		data[data[,'typ']=='NCP','typ'] <- 'NPC'
		data[substr(tolower(data[,'typ']),1,3)=='oxp','typ'] <- 'OXPHOS'
		data[substr(tolower(data[,'typ']),1,3)=='npc','typ'] <- 'NPC'
		data$typ <- as.factor(data$typ)
	}

	
	
	},
	
	message =  'Renaming columns...', value = 0)

	#Remove any fibres that have ZERO in any of the values, since intensities (or areas) of zero are invalid
	#We do occasionally have fibres that get left in matlab that have no area etc.
	to_delete <- unique(subset(data, val==0,select=c(grp, caseno, snap, id))	)
	data <- anti_join(data, to_delete)
	
	return (data)
})

observe({

	#This uses the original data, not renamed, otherwise any change in any columns triggers the cases to reset. We only want the cases column to do so.
	d <- r_dataInput()
	if (is.null(d)){return(NULL)}
	names(d)[names(d)==input$CaseCol] <- 'caseno'
	if (!("caseno" %in% colnames(d))) {return (NULL)}

	#Does not need progress
	cases <- unique(d[,'caseno'])	
	cases <- cases[order(cases)]
	#Only if they have changed
	updateSelectizeInput(session, "Controls", server=T, choices = cases,  selected = intersect(get_default_controls(),cases))
	updateSelectInput(session, "output_caseno",  choices = cases,  selected = NULL)

})

output$mess <- renderText({
})


r_model_data <- reactive({

	all_data <- r_data_merg()

	if (is.null(all_data)) {
	  print('1. No data found in r_model_data, returning NULL')
	  
	  return (NULL)}
	 
	rdata <- r_data_rand_samp()
	if (is.null(r_data_rand_samp)) {
	   print ('2. No random data, returning null')
	  return (NULL)}
	
	ch <- r_channels() #all the channels
	use <- as.logical(lapply(ch, function (x) input[[paste(x, 'use',sep='_')]])) #are they used
	norm <- as.logical(lapply(ch, function (x) input[[paste(x, 'norm',sep='_')]])) #are they to be normalised to the norm channel?

	cuts <- lapply(ch, function (x) c(-Inf, as.numeric(strsplit(input[[paste(x, 'cuts',sep='_')]],',')[[1]]), Inf)) #are they to be normalised to the norm channel?
	cut_labels <- lapply(ch, function (x) strsplit(input[[paste(x, 'cut_labels',sep='_')]],',')[[1]]) #are they to be normalised to the norm channel?

	
	withProgress(
	{
		incProgress(1/5)
		all_data <- do_models(rdata,all_data, ch, use, norm, input$NormChan, cuts, cut_labels)


		return (all_data)
		incProgress(1/5)
	},
	 message = 'Running the statistical models...',value = 0) 
})


rename_channels <- function(x) {
  #Rename the column
  ch <- r_channels_with_names()
  for (c in 1:length(ch)){
    x <- gsub(ch[c], gsub('[^[:alnum:]]','.',names(ch[c])), x)
	}
  return (x)
}



r_data_merg <- reactive({
ctrl_message <- 'There are no controls specified, so the model and regressions cannot be done. Choose controls on the first page before continuing'
  if (is.null(input$Controls)){
    mess$text <- list(ctrl_message)  
     return (NULL)
  } else {
    
    if (isolate(length(mess$text) == 1)){
      if (isolate(mess$text[[1]]  == ctrl_message)) {
        mess$text <- list()
   }}
    
  }
  controls <- as.data.frame(input$Controls)

	ch <- r_channels_with_names()
	bg_remove <- as.logical(lapply(ch, function (x) input[[paste(x, 'bg_remove',sep='_')]]))
	bg_ordered <- as.logical(lapply(ch, function (x) input[[paste(x, 'bg_ordered',sep='_')]]))
	use <- as.logical(lapply(ch, function (x) input[[paste(x, 'use',sep='_')]]))
	
	join_fields <- c('grp', 'caseno', 'snap', 'id')
	dochans <- ch[use==T]
	


	n_steps <- 10 #Just for knowing how to update the progress. Not that important at all.


	withProgress({
	 
		ox <- r_dataInput_renamed()
		if (is.null(ox) || is.na(ox) ) {return(NULL)} #|| !("typ" %in% colnames(d) now we allow typ to be blank, but no background correction if it is.


		
		if (input$TypeCol != '') {
			npc <- subset(ox, typ=='NPC', select = c(grp, caseno, channel, snap, id, val))
			print(dim(npc))

		    #Check that we have NPCs for any channel that requires correction.
		    e <-lapply(dochans, function(x) {
		     if (input[[paste(x, 'bg_remove',sep='_')]]==T
		         & !nrow(subset(npc, channel ==x)))   {
                err_message <- paste('There are no NPCs for channel',x,' but correct background is ticked on the channels page. Untick it or find the npc data!')
  			       return (err_message)
		     }
		   })
		    e <- e[!sapply(e, is.null)]
		    #Remove null ones, i.e. no error
		    if (length(e) >0) {
		      mess$text <- e
		      return (NULL)
		      } #No more processing until background is sorted.

			ox <-subset(ox, typ=="OXPHOS", select = c(grp, caseno, channel, snap, id, val))


			incProgress(1/n_steps, detail = "Calculating backgrounds")
		
			#Average background for all channels that are not ordered and that are background corrected
			npc_m <- ddply(subset(npc, channel %in% ch[use==T] & channel %in% ch[bg_remove==T] & channel %in% ch[bg_ordered==F]), c("grp", "caseno", "channel"),summarise, bg = median(val))

			#If any of the channels are 'ordered', we need to calculate the percentiles for the NORM channel. Note, I may change it so the NORM channel can be specified for each channel that is ordered.
			if (any(bg_ordered)==T) {
				incProgress(1/n_steps, detail = "Calculating normalisation channel percentiles")
				print(dim(ox))
				print(head(ox))
				print(dim(npc))
				print(head(npc))
				print(input$NormChan)
				norm_data <- subset(ox, channel==input$NormChan,select=c('grp','caseno','snap','id','val'))
				print(head(norm_data))
				norm_data <- ddply(norm_data, .(grp, caseno), pctt)
				print(head(norm_data))
				norm_data <- subset(norm_data, select = -c(val)) #Norm data gives a percentile for each (snap, id) pair for each (grp, case). Don't forget, the snap/id pair is the identifier of a fibre.
				print(head(norm_data))
				#Norm is basically a list of grp/caseno/snap/id, and the related percentile of the norm channel (usually porin)
				#The ID is specific to the snap so we need snap here, but the percentile is done over ALL snaps for that case
				all_combos <- as.data.table(merge(unique(subset(ox,select=c('grp','caseno'))), seq(from=0.00	, to=1.00, by=0.01)))
				setkey(all_combos, "grp","caseno","y") #the percentile is called y
			}
		}
		
	
		
		incProgress(1/n_steps, detail = "Matching backgrounds to signal")
#		dochans <- 'Ch3' #for debugging
		each_channel <- lapply(dochans, function(x){
			this_data <- subset(ox, channel == x,select = c(join_fields, 'val'))
			#If it is background correct, then correct it!
			ch_index = match(x,ch)
			if (bg_remove[ch_index]==T) {
				if (bg_ordered[ch_index]==T) {
					incProgress(1/n_steps, detail = paste("Calculating ", x," background percentiles"))
					#For a given case, we know the percentiles of the individual fibres (they are in norm_data)
					#We need to know what the backgrounds to match with those percentiles are. 
	
					npc_this <- as.data.table(ddply(    ddply(subset(npc,channel==x), .(grp, caseno),pctt),      .(grp, caseno, pct),summarise,bg = median(val)))
					setkey(npc_this, "grp","caseno","pct")
					npc_this <- as.data.frame(npc_this[all_combos, roll="nearest", mult="first"])
					npc_this_chan <- merge(norm_data, npc_this)
					print(unique(npc$grp))
					print(unique(npc$caseno))
					print(table(npc$caseno))
					print(head(npc_this))
					print(head(npc_this_chan))
					
					#npc_this does NOT have a snap channel. We look at npc percentiles across the whole set of snaps for this grp/case
					#we haven't touched the actual channel yet, all is done from the norm channel so far!
	
					#make a table with all the values
					incProgress(1/n_steps, detail = paste("Matching ", x," background percentiles"))

					this_data <- merge(this_data, npc_this_chan)
					this_data$val <- this_data$val - this_data$bg
					this_data <- subset(this_data, select = -c(bg,pct)) 
				} else {
	
					#subtract the mean background for this grp/case
					this_data <- merge(this_data, subset(npc_m,channel==x, select = -channel), by=c('grp','caseno'))
			
					this_data$val <- this_data$val - this_data$bg
					this_data <- subset(this_data, select = -bg)
				}
			} 
			incProgress(1/n_steps, detail = paste("Transforming", x))
			#Shift upwards so that we don't end up trying to log negative values.	
			min_val <- min(this_data$val)
			if (min_val < 0) {
				this_data$val <- this_data$val - min_val
			}
			this_data$val <- log10(this_data$val + 1) #Add ten to avoid zeros

			return (this_data)
		})
#		return (as.data.frame(each_channel[[1]])) #DEBUG
#			return (as.data.frame(each_channel[1	]))

		ox <- Reduce(function(...) merge(..., by = join_fields,all=T), each_channel)
		#To get the names right, we need to rename the last few columns
		#We rename them to the NAME assigned, not the channel ID, so that it is readable.	coltitles <- names(all_data)
		#Rename the column
		print ('#######')
			
		dochans <- lapply(dochans, clean_chan_name)
		print (dochans)
		names(ox) <- c(join_fields, rename_channels(paste('val_',dochans,sep='')))
				#Set which are controls and patients
		names(controls) <- 'caseno'
		controls$pc <- 'C'
		ox <- merge(ox,controls, by='caseno', all.x=T)
		ox[is.na(ox$pc),'pc'] <- 'P'

		dt = ox[(ox$id==1)&(ox$snap=="B068 OXPHOS"),]
		print("ox")
		print(dt)
		print(head(ox))

		return (ox)
 
	 },
	 
	 
	 message = 'Background correction',
                  value = 0 )



	})

r_control_data <- reactive({
  
    
	ox_merg <- r_data_merg()
	if (is.null(ox_merg))  {
    print('7. exiting r_control_data')
  	  return(NULL)
  }
	print('8. returning data from r_control_data')
	
		#Get the counts of each control 
	return(subset(ox_merg, pc=='C'))
})

r_rand_samp_n <- reactive({
	#The random sample size is per group
  print('5. Calculating rand sample size')
  ddply(ddply(r_control_data(), .(grp,caseno),summarise, n=length(pc)), .(grp), summarise, n = min(n))
})
	
output$prep_table <- renderDataTable({
  r <- r_data_rand_samp()
  if (!is.null(r)) {
		return (r[1:3,])
  }
  
}, options = list(paging = F, searching = F))  

output$prep_table1 <- renderDataTable({
  
  r <- r_model_data()
  if (!is.null(r)) {
    return (r[1:3,])
  }
  
}, options = list(paging = F, searching = F))  



	
	
r_data_rand_samp <- reactive({
	print('6. Generating random data')
	#Get the counts of each control 
	d_c <- r_control_data()
	if (is.null(d_c)) {
	      return (NULL)	  
	}

		 withProgress(

{		 
	incProgress(1/4)

	
	rand_samp_n <- r_rand_samp_n()

	#The rand samp needs fixed, but otherwise working.
	samp <- function(dataf)
	{
	  #The grp and caseno of the first entry will define our n
	  n <- subset(rand_samp_n, grp == dataf[1,'grp'])$n  
	  dataf[sample(1:dim(dataf)[1], size=n, replace=FALSE),]
	}
	#This is the random sample of fibres from the controls.Each group has it's own random sample
	rand_samp_merg <- ddply (d_c, .(grp,caseno), samp)
	incProgress(1/4)

	if (is.null(rand_samp_merg)) {return(NULL)}
   rand_samp_merg <- rand_samp_merg [complete.cases(rand_samp_merg), ]

	incProgress(1/4)
	
	}
	,
			 message = 'Random sampling the controls...',
		                   value = 0)


	return (rand_samp_merg)
})

output$setup_table <- renderDataTable({
#as.data.frame(do.call(rbind, r_labs()))
#r_model_data()
#r_data_merg()

v <- r_dataInput_renamed()
v[1:3,]
}, options = list(paging = F, searching = F))  

 
output$info <- renderText({
#names(r_labs())
#as.character(packageVersion("shiny"))
})  

r_control_hist <- reactive({
	data <- r_data_rand_samp()
	if (is.null(data)) {return(NULL)}
	plot_hist(data, paste('val_',clean_chan_name(input$CheckChan),sep=''), input$NormLabel)
})

r_control_pooled <- reactive({
	data <- r_data_rand_samp()
	if (is.null(data)) {return(NULL)}
	plot_hist_pooled(data, paste('val_',clean_chan_name(input$CheckChan),sep=''), input$NormLabel)
})
 
 r_all <- reactive({
	data <- r_data_merg()
	if (is.null(data)) {return(NULL)}
	plot_hist(data, paste('val_',clean_chan_name(input$CheckChan),sep=''),  input$NormLabel)
})

r_npc_graph <- reactive({
	data <- subset(r_dataInput_renamed(),typ=='NPC')# & (channel == input$NormChan | channel == input$YChan | channel == input$XChan))
	if (is.null(data)) {return(NULL)}
	data$x <- data$caseno
	data$channel <- as.factor(data$channel)
	p <- 	ggplot(data, aes(x=caseno,color=channel,y=val )) +  geom_jitter(alpha=0.5)  + theme(axis.text.x = element_text(angle = 90, hjust = 1))
return (p)
	})

r_npc_sep <- reactive({
	data <- subset(r_dataInput_renamed(),typ=='NPC')# & (channel == input$NormChan | channel == input$YChan | channel == input$XChan))
	if (is.null(data)) {return(NULL)}
	data$x <- data$caseno
	data$channel <- as.factor(data$channel)
	p <- 	ggplot(data, aes(x=caseno,color=channel,y=val )) +  geom_jitter(alpha=0.5)  + theme(axis.text.x = element_text(angle = 90, hjust = 1))+facet_wrap(~channel, scales='free_y')
return (p)
	})


r_xy <- reactive({
  if (input$CheckChan=='') {return(NULL)}
  data <- subset(r_data_merg())# & (channel == input$NormChan | channel == input$YChan | channel == input$XChan))
	if (is.null(data)) {return(NULL)}
	p <- 	ggplot(data, aes_string(y=paste('10^val_',clean_chan_name(input$CheckChan),sep=''), x=paste('10^val_',clean_chan_name(input$NormChan),sep='')))  +  
	geom_point(size=0.5)  + theme(axis.text.x = element_text(angle = 90, hjust = 1))+facet_wrap(~caseno, scales='free_y')+my_theme
return (p)
	})

r_reg_graph <- reactive({
  if (input$CheckChan=='') {return(NULL)}
  data <- r_data_rand_samp()
	if (is.null(data)) {return(NULL)}
	p <- 	ggplot(data, aes_string(y=paste('val_',clean_chan_name(input$CheckChan),sep=''), x=paste('val_',clean_chan_name(input$NormChan),sep='')))  +  
	geom_point(aes(color=caseno ),size=0.5)  +my_theme +  geom_smooth(method='lm')
return (p)
	})

	
	
r_npc_1_chan <- reactive({
  if (input$CheckChan=='') {return(NULL)}
	data <- subset(r_dataInput_renamed(), channel == input$CheckChan)
	if (is.null(data)) {return(NULL)}
	data$x <- data$caseno
	data$channel <- as.factor(data$channel)
	p <- 	ggplot(data, aes(x=caseno,color=typ,y=val )) +  geom_jitter(alpha=0.5)  + theme(axis.text.x = element_text(angle = 90, hjust = 1))
  return (p)
	})

 
output$prep_plot <- renderPlot({

  withProgress(
  
  	switch(input$graph_type, 
	'sci' = r_control_hist(),
	'scp' = r_control_pooled(),

	'a' = r_all(),
	'npc' = r_npc_graph(),
	'npc_sep' = r_npc_sep(),
	'npc_v_signal' = r_npc_1_chan() ,
	'xy' = r_xy(), 'reg' = r_reg_graph()
		
	)
, message = 'Drawing the graph',value = 0)
})  

	
output$output_table <- renderDataTable({
v <- r_model_data()
#v <- r_dataInput_renamed()
v[1:10,]
}, options = list(paging = F, searching = F))  

  
  
output$drgradientgraph <- renderPlot({

	all_data <- r_model_data() #This has progress already
	labs <- r_labs()
 withProgress(
{
	if (is.null(all_data)) {return (NULL)}
	grid.arrange(
		do_graph(input$output_caseno, all_data, input$xrange, input$yrange, labs)$page)
}
,  message = 'Drawing the graph',value = 0)


})



output$download_data <- downloadHandler(
filename = function() { 'data.csv' },
content = function(fname) {

	all_data <- r_model_data()
	coltitles <- names(all_data)
	cases <- unique(all_data$caseno)

	tmpdir <- setup_zip_dirs()
	
	path <- fname 
	fs <- c(path) 


	write.table(all_data, path, sep=', ', quote = F, row.names=F)
#	zip(zipfile=fname, files=fs)
})

setup_zip_dirs = function() {
	tmpdir <- tempdir()
	setwd(tempdir()) #hopefully persists till download!

	dir.create(file.path(tmpdir, 'pdf'))
	dir.create(file.path(tmpdir, 'tif'))
	dir.create(file.path(tmpdir, 'main'))
	return (tmpdir)
}

 test_it <- eventReactive(input$generateAll, {

 	shinyjs::disable("download_all")
#It returns a link to the zip file
  withProgress({
  
    incProgress(.1, detail = "Preparing data")

	fname <- 'output.zip'
	all_data <- r_model_data()
	cases <- unique(all_data$caseno)
	cases <- cases[order(cases)]
	
	tmpdir <- setup_zip_dirs()
	
	fs <- c()
	figs <- list();
	i <- 0

	for (caseno in cases) {
    incProgress((0.8 * nrow(cases)), detail = paste("Processing",caseno))
	i <- i + 1
	labs <- r_labs()
	d <- save_case(all_data, fs, caseno, input$xrange, input$yrange, labs)
	fs <- d$fs
	figs[[i]] <- ggplotGrob(d$main_panel+ ggtitle(caseno))
	}

    incProgress(.1, detail = "Writing csv file")

	path <- "data.csv"
	write.table(all_data, path, sep=', ', quote = F, row.names=F)
	fs <- c(fs, path)

	
	#the marrangeGrob is currently failing, need to test it. Want to panel the outputs onto a small page.
#	ml <- figs[[1]]
ml <- marrangeGrob(figs, nrow=3, ncol=2, top=NULL)
file1 <- 'multipage.pdf'
ggsave(file1, ml,width=10, height=10*1.414,units='in')
fs <- c(fs, file1)

	shinyjs::enable("download_all")
	
	}
	


	
	
	
, message = 'Extracting data',value = 0)

		fs
		
		})
  
  output$test_out <- renderText({test_it()})



output$download_all <- downloadHandler(
filename = function() { 'output.zip' },
content = function(fname) {

withProgress({
  
    incProgress(.1, detail = "Zipping")

	zip(zipfile=fname, files=test_it())
	}, message = 'Zipping',value = 0)
	
})

  


#output$out_table <- renderDataTable({
##
#		r_model_data()[1:3,]
#
#}, options = list(paging = F, searching = F))  



output$download_this <- downloadHandler(
filename = function() { paste('output.zip', sep='') },
content = function(fname) {

	all_data <- r_model_data()
	labs <- r_labs()
	tmpdir <- setup_zip_dirs()

	x <- save_case(all_data, c(), input$output_caseno,input$xrange, input$yrange, labs)
	fs <- x$fs
	
	zip(zipfile=fname, files=fs)
})



output$setup_channels <- renderUI({
	#This generates a line for each channel, once the channels are loaded from the file. 	
	#We do it with the NAMED items. This is so that any re-assignments ignores the actual channel numbers and just deals with the names
	ch <- r_channels_with_names() 	
	
	#Ok, the ch is  a list of channels, but by the time it is passed in as an item to the lapply, it loses it's name.
	#So we need to make a list of pairs of val and name.
	
	#From this http://stackoverflow.com/questions/9469504/access-and-preserve-list-names-in-lapply-function, it is a bit weird to try to access both names and the values within lapply#
	#But I need both. I could create a list of pairs of values. But this is a weird way to do it that is more concise. If a little totally weird to read

	n <- names(ch)
	
	tags <- tagList(
		lapply(setNames(n, n), function(nameindex)
		{
			nm <- nameindex #which is the name, e.g. Porin
			x <- ch[[nameindex]] #The original value, eg. Ch1
			fluidRow(tagList(
			column(2, p(input[[paste(x,'label',sep='_')]])),
			column(1,checkboxInput(paste(x,'bg_remove',sep='_'), NULL, value = get_default_bg_remove(nm))),
			column(1,checkboxInput(paste(x,'bg_ordered',sep='_'), NULL, value = get_default_bg_ordered(nm))),
			column(1,checkboxInput(paste(x,'norm',sep='_'), NULL, value = get_default_norm(nm))),
			column(1, textInput(paste(x,'cuts',sep='_'), NULL, get_default_cuts(nm))),
			column(3, textInput(paste(x,'cut_labels',sep='_'), NULL, get_default_cut_labels(nm)))
		))
	}))
	return(tags)
})

output$choose_channels <- renderUI({
	#This generates a line for each channel, once the channels are loaded from the file. 	
	ch <- r_channels_all() 	
	tags <- tagList(lapply(ch, function (x) {
		fluidRow(tagList(
		column(1, p(x)),
		column(2, textInput(paste(x,'label',sep='_'), NULL, get_default_label(x))),
		column(1,checkboxInput(paste(x,'use',sep='_'), NULL, value = get_default_use(get_default_label(x))))
		))
	}))
	return(tags)
})
	
r_channels <- reactive({
	#This now only returns the channels that are marked in use. After the first page of the website this is the only list of channels to refer to
	all_channels <- r_channels_all()
	ch <- do.call(rbind,  lapply(all_channels, 
		function(x) { 
			v <- input[[paste(x, '_use',sep='')]]
			if (!is.null(v)){ if (v==T) { return (x) }}}
		))

	if (is.null(ch)) {ch <- 'Hello'}
		
	return (ch)
})

r_channels_all <- reactive({
	d <- r_dataInput()
	if (is.null(d))  {return (NULL)}
	return (unique(d$channel))
})

r_channels_with_names <- reactive({
	#This is used for populating any listboxes that offer options of channels (e.g. for choosing X axis, Y axis, etc)
	#It updates if the labels of the channels are altered etc.
	ch <- r_channels()
	if (!is.null(ch)){
		names(ch) <- lapply(ch, function (x) input[[paste(x, '_label',sep='')]])
		#The name of each channel is the original channel code
		return (ch)
	}
})


observe({
	ch <- r_channels_with_names()
#		if (!is.null(ch))
#		{
	#Don't put this in r_channels_with_names! If you do, it frikkin recalculates every time you choose a different verification graph!
	chan_cols <- c('NormChan','ColourChan','XChan','YChan','AreaChan','CheckChan')
	sapply(chan_cols, function (x) updateSelectInput(session, x, choices = ch,  selected =  ifelse(input[[x]]=='',get_default_channel(x),input[[x]])))
#		}
#	}
	})

})




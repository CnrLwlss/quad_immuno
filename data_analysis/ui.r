library(shiny)
library(shinyjs)

chart_options <- c('Bar chart'='bc','Histogram'='h', 'No graph' = 'x')

graphs_list <-	c( 
	'Sampled controls' = 'sci',
	'Pooled sampled controls' = 'scp',
	'All cases' = 'a',
	'NPCs' = 'npc',
	'NPCs (separate panels)' = 'npc_sep',
	'NPCs vs Signal' = 'npc_v_signal',
	'XY verification graphs'='xy',
	'Regression vs normalisation channel' = 'reg'
)

# Define UI for application that plots random distributions 
shinyUI(tagList(useShinyjs(),navbarPage(
	title = 'Mitochondrial immunofluorescence analysis',
	tabPanel('Load',   

		fluidRow(
			column(4,
				fileInput('file1', 'File',	accept = c(	'text/csv',	'text/comma-separated-values','text/tab-separated-values','text/plain','.csv','.tsv')),
				textInput('separator','Separator',value=' '),
				p('Choose a CSV file to upload. You can also break the filename by separator character(s)... leave the separator box blank to leave it as one field. You can just type a single space if required.')
			),
			column(4,
				selectInput('TypeCol', 'Type (OXPHOS/NPC)',c()),
				selectInput('SnapCol', 'Snap (usually Filename)',c())
			),
			column(4,
				selectInput('CaseCol', 'Subject IDs',c()),
				selectizeInput('Controls', 'Which Subject IDs are controls?',c(),multiple = T)
			)
		),

		fluidRow(	
			column(1, p('Channel')),
			column(2, p('Label')),
			column(1, p('Use'))
		),

		uiOutput("choose_channels"),

		hr(),

		fluidRow(	
			dataTableOutput("setup_table")
		),

		fluidRow(		  
			verbatimTextOutput("errors"),
			p('Info:'),
			verbatimTextOutput("info")
		)
	),

	tabPanel('Channels',     
 	       fluidRow(
 	         column(1,strong("Assign channels")),
 	         column(2,selectInput('NormChan', 'Normalisation',c())),
            column(2,selectInput('XChan', 'X axis',c())),
            column(2,selectInput('YChan', 'Y axis',c())),
            column(2,selectInput('ColourChan', 'Colour',c())),
            column(2,selectInput('AreaChan', 'Area',c()))
    		  ),

    		  fluidRow(
    		    column(1,strong("Graph to display")),
    		    column(2,p()),
    		    column(2,selectInput('XGraph', '',chart_options,selected='bc')),
    		    column(2,selectInput('YGraph', '',chart_options,selected='bc')),
    		    column(2,selectInput('ColourGraph', '',chart_options,selected='h')),
    		    column(2,selectInput('AreaGraph', '',chart_options,selected='x'))
    		  ),
    		  
    		  			
		fluidRow(	
			column(2, p('Channel')),
			column(1, p('Remove background')),
			column(1, p('Ordered background')),
			column(1, p('Normalise')),
			column(1, p('Cutoffs')),
			column(3, p('Cutoff labels'))
		),

		uiOutput("setup_channels")
	),
	
	tabPanel('Check data',     
 		fluidRow(
 		  column(3,selectInput('graph_type', 'Output to display', graphs_list)),
 		  column(2,selectInput('CheckChan', 'Channel',c()))
 		),
 		plotOutput("prep_plot",width = "800px"),
		p('Random sample data table'),
		dataTableOutput("prep_table"),
		p('Output data with z scores and categories'),
		dataTableOutput("prep_table1"),
		verbatimTextOutput("prep_err")
	),
	  
	tabPanel('Output',        
		fluidRow(
		  column(4,
		        fluidRow(
		          column(1,p()),
		          column(6,selectInput('output_caseno', 'Subject ID',c()))
	          ),
		        fluidRow(
		          column(5,actionButton('generateAll', 'Generate all')),
		            column(5,downloadButton('download_all', label = "Download all", class = NULL))
            ),
		        fluidRow(
        			column(5,downloadButton('download_this', label = "Download this", class = NULL)),
  			      column(5,downloadButton('download_data', label = "Download all data", class = NULL))
		        ),
		        fluidRow(
		          column(10,sliderInput("xrange", label = strong("x range"), min = -50, max = 10, value = c(-26,4)))
	          ),
		        fluidRow(
		          column(10,sliderInput("yrange", label = strong("y range"), min = -50, max = 10, value = c(-26,4)))
		        ),
		        fluidRow(verbatimTextOutput("test_out"))
		  ),
		  column(8, plotOutput("drgradientgraph",width = "600px", height="848px"))
		  )
	)
)))


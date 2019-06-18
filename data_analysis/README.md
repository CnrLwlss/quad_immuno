# immuno

This is a shiny app for R.  Along with shiny itself, it also depends on several other R packages.  To set up R to run this app locally:

~~~~
install.packages(c("shiny","shinyjs","dplyr","ggplot2","gridExtra"))
~~~~

Once your R installation is ready, to run the app, simply set your working directory to the directory containing server.r and ui.r and run:

~~~~
library(shiny)
runApp()
~~~~

#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
#packages go here
library(shiny)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)
theme_set(theme_minimal())


# Define UI for application that draws a histogram
ui <- fluidPage(

        selectInput('selectfile','Select File',choice = list.files('Data/Flow Data')),
        mainPanel(plotlyOutput("plot")                                                                            

))

# Define server logic required to draw a histogram
server <- function(input, output) {

  
  
  Flow.data <- reactive({
    
    in.file <- input$selectfile
    txt.str= paste('Data/Flow Data/',in.file,sep = "")
    data= read.csv(txt.str)
    #data=in.file
    
    data$X=as.character(data$X)
    data$date.time=strptime(data$X, format="%Y-%m-%d %H:%M:%S") 
    data$date.time = as.POSIXct(data$date.time)
    return(data)
  })
  
  Calibration.data <- reactive({
    
    in.file <- input$selectfile
    site_id=substr(in.file, 0, 7)
   
    txt.str= paste('Data/Compiled Calibrations/',site_id,'_compiled.csv',sep = "")
    data= read.csv(txt.str)
    #data=in.file
   # class(data$Datetime)
    
    #data$X=as.character(data$X)
   
    #data$date.time=strptime(data$X, format="%Y-%m-%d %H:%M:%S") 
    #data$date.time = as.POSIXct(data$date.time)
    return(data)
  })
  
  output$plot <- renderPlotly({
    flowpoints=Flow.data() 
    calpoints=Calibration.data()
    
  
    p <- ggplot(calpoints, aes(Flow..gpm..no.stormflow, Flow_gpm_1)) + geom_point()+ geom_abline(intercept=0, slope= 1)
   ggplotly(p)
    
})
}
# Run the application 
shinyApp(ui = ui, server = server)

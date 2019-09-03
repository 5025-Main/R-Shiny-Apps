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


rmse <- function(error)
{
  sqrt(mean(error^2,na.rm=TRUE))
}

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
   
    txt.str= paste('Data/Compiled Calibrations/',site_id,'-compiled.csv',sep = "")
    data= read.csv(txt.str)

    return(data)
  })
  
  output$plot <- renderPlotly({
   
     flowpoints=Flow.data() 
    calpoints=Calibration.data()
    
    df3 <- calpoints %>%
      select(Datetime,Flow..gpm..no.stormflow, Flow_gpm_1,Flow_gpm_2,Flow_gpm_3) %>%
      gather(key = "variable", value = "Manual.meas", -Datetime,-Flow..gpm..no.stormflow) 
    
   
    
   
    error <-df3$Manual.meas- df3$Flow..gpm..no.stormflow
    
    rmse.cal=rmse(error)
    
    
    
    
    g <- ggplot(df3, aes(x=Flow..gpm..no.stormflow,y= Manual.meas, text= paste("Manual Measurement Date :", Datetime )))+
    geom_point()+geom_abline(intercept=0, slope= 1)+
      labs(x="Flow Predicted (GPM), no stormflow", y="Manual Field Measurement")+
      geom_text(x = 1, y = 2,label=paste("RMSE:",rmse.cal),parse = TRUE)
    
    
    gg<- ggplotly(g)
    
    
    gg<-layout(
      title = "Time Series with Custom Date-Time Format",
      xaxis = list(
        type = 'date',
        tickformat = "%d %B (%a)<br>%Y"
      ))
    
})
}
# Run the application 
shinyApp(ui = ui, server = server)

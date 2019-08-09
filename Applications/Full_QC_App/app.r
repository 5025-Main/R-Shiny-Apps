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
options(shiny.reactlog=TRUE) 

# User interface ----

ui <- fluidPage(
  fluidRow(
    column(3,
          
            selectInput('selectfile','Select File',choice = list.files('Data/Flow Data/')),
  
                        checkboxGroupInput("checkGroup", label = h3("Select Parameters for Timeseries plot"),
                                           c("Level_in" = "Level_in",
                                             "Level_in_clipped" = "Level_in_clipped",
                                             "Flow_gpm"="Flow..gpm.",
                                             "Flow_gpm_nostormflow" ="Flow..gpm..no.stormflow",
                                             "Flow_gpm_USBR" ="Flow..gpm..USBR"), 
                                           selected = "Level_in")
    
    ),
  column(9,
 plotlyOutput("plot"),
 plotlyOutput("plot2"))


))

# Server logic ----
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
  
 ranges <- reactiveValues(x = NULL, y = NULL)
  
  output$plot <- renderPlotly({
    Flow.plot.data=Flow.data() 
   
    Flow.data.long <- reactive({
      df2 <- Flow.plot.data %>%
        select(date.time, input$checkGroup) %>%
        gather(key = "variable", value = "value", -date.time) 
      return(df2)
    })
    
    df2=Flow.data.long()
   
    # Multiple line plot
   hydroplot<- ggplot(df2, aes(x = as.POSIXct(date.time), y = value)) + 
      # scale_color_manual(values = c("#FF0000","#00FF00	","#0000FF"	,"#FFFF00"	,"#00FFFF"))+
      geom_line(aes(color = variable), size = 1) +
      # scale_color_brewer(palette="Dark2")
      #geom_line(data = df3, aes(x = as.POSIXct(date.time), y = value))+
      geom_line(aes(color = variable), size = 1)+
      # scale_color_manual(values = c("#FF00FF","#C0C0C0	","#800000	"	,"#808000	"	,"#008080	"))+
      #scale_color_manual(values = c(mypalette2)) + 
      labs(title=paste("Plotting",input$selectfile),
           x ="Date", y = input$checkGroup)+
      coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE)
    ggplotly(hydroplot)
  })
  
  
  
  output$plot2 <- renderPlotly({
  
      calpoints=Calibration.data()
      
      df3 <- calpoints %>%
        select(Datetime,Flow..gpm..no.stormflow, Flow_gpm_1,Flow_gpm_2,Flow_gpm_3) %>%
        gather(key = "variable", value = "value", -Datetime,-Flow..gpm..no.stormflow) 
      
      
      
      g <- ggplot(df3, aes(x=Flow..gpm..no.stormflow,y= value, text= paste("Manual Measurement Date :", Datetime )))+geom_point()+geom_abline(intercept=0, slope= 1)
      
      
      ggplotly(g)
    
  })
  
}

# Run app ----
shinyApp(ui, server)

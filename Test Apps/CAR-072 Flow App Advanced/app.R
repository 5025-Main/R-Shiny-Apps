#packages go here
library(shiny)
library(tidyr)
library(dplyr)
library(ggplot2)
theme_set(theme_minimal())

#global variables go here


#in.file= read.csv("Data/CAR-072-Flow.csv")
#data=in.file

#data$X=as.character(data$X)

#data$date.time=as.Date(data$X, format="%Y-%m-%d %H:%M:%S")   
#data$date.time=strptime(data$X, format="%Y-%m-%d %H:%M:%S") 
#data$date.time = as.POSIXct(data$date.time)

options(shiny.reactlog=TRUE) 

# User interface ----

ui <- fluidPage(
  selectInput('selectfile','Select File',choice = list.files('Data/')),
  textOutput('fileselected'),
  
  selectInput("var", 
              label = "Choose a variable to display",
              choices = c("Level_in", "Level_in_clipped","Flow_gpm","Flow_gpm_nostormflow","Flow_gpm_USBR"),
              selected = "Level_in"),
  
  selectInput("var2", 
              label = "Choose a secondary variable to display",
              choices = c( "None","Level_in", "Level_in_clipped","Flow_gpm","Flow_gpm_nostormflow","Flow_gpm_USBR"),
              selected = ""),

  #dateRangeInput("daterange1", "Date range:",
               #  start = "2015-05-01",
               #  end   = "2018-9-30"),
  
  mainPanel(h4("Brush and double-click to select date range"), plotOutput("plot",
                       dblclick = "plot_dblclick",
                       brush = brushOpts(
                         id = "plot_brush",
                         resetOnNew = TRUE)))
  )



# Server logic ----
server <- function(input, output) {
  
  mydata <- reactive({
 
  in.file <- input$selectfile
  txt.str= paste('Data/',in.file,sep = "")
  data= read.csv(txt.str)
  #data=in.file
  
  data$X=as.character(data$X)
  data$date.time=strptime(data$X, format="%Y-%m-%d %H:%M:%S") 
  data$date.time = as.POSIXct(data$date.time)
  return(data)
  
   })
  
  ranges <- reactiveValues(x = NULL, y = NULL)
  
  output$plot <- renderPlot({
    data.m=mydata() 
    param <- switch(input$var, 
                    "Level_in" = "Level_in",
                    "Level_in_clipped" = "Level_in_clipped",
                    "Flow_gpm"="Flow..gpm.",
                   "Flow_gpm_nostormflow" ="Flow..gpm..no.stormflow",
                   "Flow_gpm_USBR" ="Flow..gpm..USBR")
    
    param2= switch(input$var2, 
                   "Level_in" = "Level_in",
                   "Level_in_clipped" = "Level_in_clipped",
                   "Flow_gpm"="Flow..gpm.",
                   "Flow_gpm_nostormflow" ="Flow..gpm..no.stormflow",
                   "Flow_gpm_USBR" ="Flow..gpm..USBR")
  
     
    df2 <- data.m %>%
      select(date.time, param, param2) %>%
      gather(key = "variable", value = "value", -date.time)
   
    
    # Multiple line plot
    ggplot(df2, aes(x = as.POSIXct(date.time), y = value)) + 
      geom_line(aes(color = variable), size = 1) +
      scale_color_manual(values = c("#00AFBB", "#E7B800")) + 
      labs(title=paste("Currently plotting",input$selectfile),
           x ="Date", y = param)+
      theme_minimal()+coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE)
    
    
})

  observeEvent(input$plot_dblclick, {
    brush <- input$plot_brush
    if (!is.null(brush)) {
      ranges$x <- c(as.POSIXct(brush$xmin,origin = "1970-01-01"), as.POSIXct(brush$xmax,origin = "1970-01-01"))
     
      ranges$y <- c(brush$ymin, brush$ymax)
      
    } else {
      ranges$x <- NULL
      ranges$y <- NULL
    }
  })
  
}

# Run app ----
shinyApp(ui, server)

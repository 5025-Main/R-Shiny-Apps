#packages go here
library(shiny)
library(tidyr)
library(dplyr)
library(ggplot2)
theme_set(theme_minimal())

# if we were using global variables, they would go here. This script is using user inputs from the Data/ file, so no need for global va




options(shiny.reactlog=TRUE) 

# User interface ----

ui <- fluidPage(
  selectInput('selectfile','Select File',choice = list.files('Data/')),
  selectInput('selectfile2','Select File to compare',choice = list.files('Data/'),selected = "None"),
  
  #selectInput("var", 
             # label = "Choose a variable to display",
              #choices = c("Level_in", "Level_in_clipped","Flow_gpm","Flow_gpm_nostormflow","Flow_gpm_USBR"),
              #selected = "Level_in"),
  
  #selectInput("var2", 
              #label = "Choose a secondary variable to display",
              #choices = c( "None","Level_in", "Level_in_clipped","Flow_gpm","Flow_gpm_nostormflow","Flow_gpm_USBR"),
             # selected = ""),

  # input parameters
  checkboxGroupInput("checkGroup", label = h3("Select Parameters"),
               c("Level_in" = "Level_in",
               "Level_in_clipped" = "Level_in_clipped",
               "Flow_gpm"="Flow..gpm.",
               "Flow_gpm_nostormflow" ="Flow..gpm..no.stormflow",
               "Flow_gpm_USBR" ="Flow..gpm..USBR"), 
               selected = "Level_in"),
  
  mainPanel(h4("Brush and double-click to select date range (Double-click anywhere to reset)"), plotOutput("plot",
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
  
  mydata2 <- reactive({
    
    in.file2 <- input$selectfile2
    txt.str2= paste('Data/',in.file2,sep = "")
    data2= read.csv(txt.str2)
    #data=in.file
    
    data2$X=as.character(data2$X)
    data2$date.time=strptime(data2$X, format="%Y-%m-%d %H:%M:%S") 
    data2$date.time = as.POSIXct(data2$date.time)
    return(data2)
    
  })
  
  ranges <- reactiveValues(x = NULL, y = NULL)
  
  output$plot <- renderPlot({
    data.m=mydata() 
    data.2=mydata2()
    #param <- switch(input$var, 
                  #  "Level_in" = "Level_in",
                  #  "Level_in_clipped" = "Level_in_clipped",
                 #   "Flow_gpm"="Flow..gpm.",
                 #  "Flow_gpm_nostormflow" ="Flow..gpm..no.stormflow",
                 #  "Flow_gpm_USBR" ="Flow..gpm..USBR")
   # param4 <- switch(input$checkGroup, 
                   # "Level_in" = "Level_in",
                   # "Level_in_clipped" =2,
                    #"Flow_gpm"=3,
                   #"Flow_gpm_nostormflow" =4,
                   # "Flow_gpm_USBR" =5)
    
  #  param2= switch(input$var2, 
                  # "Level_in" = "Level_in",
                  # "Level_in_clipped" = "Level_in_clipped",
                  # "Flow_gpm"="Flow..gpm.",
                  # "Flow_gpm_nostormflow" ="Flow..gpm..no.stormflow",
                  # "Flow_gpm_USBR" ="Flow..gpm..USBR")
 
    dataset1 <- reactive({
    df2 <- data.m %>%
      select(date.time, input$checkGroup) %>%
      gather(key = "variable", value = "value", -date.time) 
    return(df2)
    })
    
    df2=dataset1()
    
    dataset2 <- reactive({
    df3 <- data.2 %>%
      select(date.time, input$checkGroup) %>%
      gather(key = "variable", value = "value", -date.time) 
    return(df3)
    })
    df3=dataset2()

    
   # colorvec <- reactive({
  ##  z=input$checkGroup
    #return(z)
   # })
    
   # colors=colorvec()
   # num.colors=length(colors)
    
    
   # mypalette<-brewer.pal(num.colors,"Set1")
   # mypalette2<-brewer.pal(num.colors,"Set3")
    
    
    
    # Multiple line plot
    ggplot(df2, aes(x = as.POSIXct(date.time), y = value)) + 
     # scale_color_manual(values = c("#FF0000","#00FF00	","#0000FF"	,"#FFFF00"	,"#00FFFF"))+
      geom_line(aes(color = variable), size = 1) +
   # scale_color_brewer(palette="Dark2")
      geom_line(data = df3, aes(x = as.POSIXct(date.time), y = value))+
      geom_line(aes(color = variable), size = 1)+
     # scale_color_manual(values = c("#FF00FF","#C0C0C0	","#800000	"	,"#808000	"	,"#008080	"))+
      #scale_color_manual(values = c(mypalette2)) + 
      labs(title=paste("Plotting",input$selectfile,"and",input$selectfile2),
           x ="Date", y = input$checkGroup)+
      coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE)
    
})

  
  ######Server side clicky zoomy function #####
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

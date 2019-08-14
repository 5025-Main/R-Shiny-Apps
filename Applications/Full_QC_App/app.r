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
library(leaflet)
library(shinythemes)
library(readxl)
library(Metrics)


r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

X2019_MS4_Sites <- read_excel("Data/2019_MS4 Sites.xlsx")


sites.2019= X2019_MS4_Sites [c(9,14)]
sites.2019=as.data.frame(sites.2019)

sites.2019$lng=sapply(strsplit(sites.2019$`ns1:coordinates`,","),"[",1)
sites.2019$lat=sapply(strsplit(sites.2019$`ns1:coordinates`,","),"[",2)

sites.2019$lng=as.numeric(sites.2019$lng)
sites.2019$lat=as.numeric(sites.2019$lat)


#rmse function
rmse <- function(error)
{
  sqrt(mean(error^2,na.rm=TRUE))
}

# User interface ----

ui <- fluidPage(theme = shinytheme("superhero"),
  fluidRow(
    column(3,
          
            selectInput('selectfile','Select File',choice = list.files('Data/Flow Data/')),
  
                        checkboxGroupInput("checkGroup", label = h3("Select Parameters for Timeseries plot"),
                                           c("Level (in)" = "Level_in",
                                             "Level Clipped (in)" = "Level_in_clipped",
                                             "Flow (gpm)"="Flow..gpm.",
                                             "Flow (gpm) - no stormflow" ="Flow..gpm..no.stormflow",
                                             "Flow (gpm)- USBR" ="Flow..gpm..USBR"), 
                                           selected = "Level_in"),
          
            leafletOutput("mymap")
    
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
    data$date.time=as.POSIXct(strptime(data$X, format="%Y-%m-%d %H:%M:%S")) 
    return(data)
    
  })
  
  Calibration.data <- reactive({
    
    in.file <- input$selectfile
    site_id=substr(in.file, 0, 7)
    
    txt.str= paste('Data/Compiled Calibrations/',site_id,'-compiled.csv',sep = "")
    data= read.csv(txt.str)
    
    return(data)
  })
  
  site_id <- reactive({
    
    in.file <- input$selectfile
    site_id=substr(in.file, 0, 7)
    return(site_id)
  })
  
 ranges <- reactiveValues(x = NULL, y = NULL)
  
  output$plot <- renderPlotly({
    Flow.plot.data=Flow.data() 
    site_id=site_id()
   
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
      labs(title=paste("Plotting site data for",site_id),
           x ="Date", y = input$checkGroup)+
      coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE)
    ggplotly(hydroplot)
  })
  
  
  
  output$plot2 <- renderPlotly({
  
      calpoints=Calibration.data()
      
      df3 <- calpoints %>%
        select(Datetime,Flow..gpm..no.stormflow, Flow_gpm_1,Flow_gpm_2,Flow_gpm_3) %>%
        gather(key = "variable", value = "Manual.meas", -Datetime,-Flow..gpm..no.stormflow) 
      
      
      
      error <-df3$Manual.meas- df3$Flow..gpm..no.stormflow
      
      rmse.cal=rmse(error)
      
      
      g <- ggplot(df3, aes(x=Flow..gpm..no.stormflow,y= Manual.meas, text= paste("Manual Measurement Date :", Datetime )))+
        geom_point(color='darkblue')+geom_abline(intercept=0, slope= 1)+
        labs(x="Flow Predicted (gpm), no stormflow", y="Manual Field Measurement (gpm)")+
        geom_text(x = 1, y = 2,label=paste("RMSE:",rmse.cal),parse = TRUE)
      
      
      ggplotly(g)
    
  })
  
  
  output$mymap <- renderLeaflet({
    site_id=site_id()
    leaflet(sites.2019) %>%addTiles() %>% addMarkers(sites.2019$lng,sites.2019$lat, label = sites.2019$`ns1:name3`) 
  })
  
    center <- reactive({
      site_id=site_id()
      site.subset=sites.2019[grep(site_id, sites.2019$`ns1:name3`),]
      return(site.subset[1,])
       })
    
    observe({
      leafletProxy('mymap') %>% 
        setView(lng =  center()$lng, lat = center()$lat, zoom = 16)
    })
    
  
}

# Run app ----
shinyApp(ui, server)

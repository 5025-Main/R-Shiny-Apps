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

options(shiny.reactlog=TRUE) 

# User interface ----

ui <- navbarPage(title = "WAQA (Wood App For Quality Assurance)" , theme = shinytheme("superhero"),
                 tabPanel('Home',
                  fluidRow(         
             column(3,
          
            selectInput('selectfile','Select File',choice = list.files('Data/Flow Data/'),selected = "CAR-070-Flow.csv"),
  
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
 plotlyOutput("plot2"),
 plotlyOutput("plot3")
 )


)),

tabPanel('Compare Sites',
         fluidRow(
           column(3,
           selectInput('selectfile3','Select File',choice = list.files('Data/Flow Data')),
           selectInput('selectfile4','Select File to compare',choice = list.files('Data/Flow Data')),#,selected = "CAR-072O-Flow.csv"),
           
           # input parameters
           checkboxGroupInput("checkGroup2", label = h3("Select Parameters"),
                              c("Level (in)" = "Level_in",
                                "Level Clipped (in)" = "Level_in_clipped",
                                "Flow (gpm)"="Flow..gpm.",
                                "Flow (gpm) - no stormflow" ="Flow..gpm..no.stormflow",
                                "Flow (gpm)- USBR" ="Flow..gpm..USBR"), 
                              selected = "Level_in")
             )
           ), 
           
           column(9,  
                     plotlyOutput("site_compare")
         
    )         
  )
)

# Server logic ----
server <- function(input, output, session) {

  output$Home <-
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
           x ="Date", y = input$checkGroup2)+
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
  
  output$plot3 <- renderPlotly({
    
    calpoints=Calibration.data()
    
    
    level.df <- calpoints %>%
      select(Datetime,Level_in_clipped, Level_above_V_in_Before)
    
    error2 <-level.df$Level_above_V_in_Before- level.df$Level_in_clipped
    
    rmse.cal2=rmse(error2)
    
    
    h <- ggplot(level.df, aes(x=Level_above_V_in_Before,y= Level_in_clipped, text= paste("Manual Level Measurement Date :", Datetime )))+
      geom_point(color='aquamarine4')+geom_abline(intercept=0, slope= 1)+
      labs(x="Level_above_V_in_Before", y="Level_in_clipped")+
      geom_text(x = .6, y = .75,label=paste("RMSE:",rmse.cal2),parse = TRUE)
    
    
    ggplotly(h)
    
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
    
  
    
    output$'Compare Sites' <- 

       Flow.data2 <- reactive({
        
        in.file <- input$selectfile3
        txt.str= paste('Data/Flow Data/',in.file,sep = "")
        data= read.csv(txt.str)
        #data=in.file
        
        data$X=as.character(data$X)
        data$date.time=as.POSIXct(strptime(data$X, format="%Y-%m-%d %H:%M:%S")) 
        return(data)
      })
    
    Flow.data3 <- reactive({
      
      in.file <- input$selectfile4
      txt.str= paste('Data/Flow Data/',in.file,sep = "")
      data= read.csv(txt.str)
      #data=in.file
      
      data$X=as.character(data$X)
      data$date.time=as.POSIXct(strptime(data$X, format="%Y-%m-%d %H:%M:%S")) 
      return(data)
    })
      
   
      ranges2 <- reactiveValues(x = NULL, y = NULL)
     
      output$site_compare <-renderPlotly({
       
         Flow.plot.data2 =Flow.data2()
        Flow.plot.data3 =Flow.data3()
         
         
         
         Flow.data.long2 <- reactive({
           df4 <- Flow.plot.data2 %>%
             select(date.time, input$checkGroup2) %>%
             gather(key = "variable", value = "value", -date.time) 
           return(df4)
         })
         
         
         Flow.data.long3 <- reactive({
           df5 <- Flow.plot.data3 %>%
             select(date.time, input$checkGroup2) %>%
             gather(key = "variable", value = "value", -date.time) 
           return(df5)
         })
      
      df4=Flow.data.long2()
      df5=Flow.data.long3()
      
      
      hydroplot2<- ggplot(df4, aes(x = as.POSIXct(date.time), y = value)) + 
      # scale_color_manual(values = c("#FF0000","#00FF00	","#0000FF"	,"#FFFF00"	,"#00FFFF"))+
      geom_line(aes(color = variable), size = 1) +
      # scale_color_brewer(palette="Dark2")
      geom_line(data = df5, aes(x = as.POSIXct(date.time), y = value))+
      geom_line(aes(color = "variable" ), size = 1)+
      # scale_color_manual(values = c("#FF00FF","#C0C0C0	","#800000	"	,"#808000	"	,"#008080	"))+
      #scale_color_manual(values = c(mypalette2)) + 
      labs(title=paste("Plotting site data for",input$selectfile3,"and",input$selectfile4),
           x ="Date", y = input$checkGroup2)+
      coord_cartesian(xlim = ranges2$x, ylim = ranges2$y, expand = FALSE)
   
       ggplotly(hydroplot2)
       
       
     
        
})

}

# Run app ----
shinyApp(ui, server)

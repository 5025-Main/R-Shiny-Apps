#packages go here

library(tidyr)
library(dplyr)
library(ggplot2)
theme_set(theme_minimal())

#global variables go here

in.file= read.csv("Data/CAR-072-Flow.csv")
data=in.file

data$X=as.character(data$X)

data$date.time=as.Date(data$X, format="%Y-%m-%d %H:%M:%S")   #this is still formatting wrong for some reason. Missing times

data$date.time[1:20]

#plot below is the template of what we're going for
plot(data$date.time,data$Level_in,type = "l")

# User interface ----

ui <- fluidPage(
  
  selectInput("var", 
              label = "Choose a variable to display",
              choices = c("Level_in", "Level_in_clipped","Flow_gpm","Flow_gpm_nostormflow","Flow_gpm_USBR"),
              selected = "Level_in"),
  selectInput("var2", 
              label = "Choose a secondary variable to display",
              choices = c( "None","Level_in", "Level_in_clipped","Flow_gpm","Flow_gpm_nostormflow","Flow_gpm_USBR"),
              selected = ""),

  dateRangeInput("daterange1", "Date range:",
                 start = "2015-05-01",
                 end   = "2018-9-30"),
  
  mainPanel(plotOutput("plot"))
  )



# Server logic ----
server <- function(input, output) {
  output$plot <- renderPlot({
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
  
    df2 <- data %>%
      select(date.time, param, param2) %>%
      gather(key = "variable", value = "value", -date.time)
   
    
    # Multiple line plot
    ggplot(df2, aes(x = date.time, y = value)) + 
      geom_line(aes(color = variable), size = 1) +
      scale_color_manual(values = c("#00AFBB", "#E7B800")) +
      theme_minimal()
    
    
})

}

# Run app ----
shinyApp(ui, server)

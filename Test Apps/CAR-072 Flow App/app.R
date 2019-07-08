#install.packages("zoo")
library(zoo)

in.file= read.csv("Data/CAR-072-Flow.csv")
data=in.file
data.ts=zoo(data)

data$X=as.character(data$X)

data$date.time=as.Date(data$X, format="%Y-%m-%d %H:%M:%S")   #this is still formatting wrong for some reason. Missing times

data$date.time[1:20]

#plot below is what we're going for
plot(data$date.time,data$Level_in,type = "l")

# User interface ----

ui <- fluidPage(
  
  selectInput("var", 
              label = "Choose a variable to display",
              choices = c("Level_in", "Level_in_clipped"),
              selected = "Level_in"),
  
  sliderInput("range", 
              label = "Date Range:",
              min = 0, max = 100, value = c(0, 100)),
  
  
  
  mainPanel(plotOutput("plot"))
)



# Server logic ----
server <- function(input, output) {
  output$plot <- renderPlot({
    param <- switch(input$var, 
                    "Level_in" = data$Level_in,
                    "Level_in_clipped" = data$Level_in_clipped)
    
    
    
    plot(data$date.time, param , type = "l")
  })
}



# Run app ----
shinyApp(ui, server)

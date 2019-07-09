library(shiny)
library(readxl)
library(datasets)
CAR_070_Compiled_Level <- read_excel("Data/CAR-070 Compiled Level.xlsx")
x <- t(x)
colnames(x) <- x[1, ]
x <- x[-1, ]
x


function(input, output) {
  
  # Fill in the spot we created for a plot
  output$phonePlot <- renderPlot({
    
    
    # Render a barplot
    plot(CAR_070_Compiled_Level$Timestamp[,input$probe], 
           main=input$probe,
            ylab="level.in",
            xlab="Date")
    
  })
}
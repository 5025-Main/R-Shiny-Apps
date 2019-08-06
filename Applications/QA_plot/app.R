#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
#packages go here
library(shiny)
library(tidyr)
library(dplyr)
library(ggplot2)
theme_set(theme_minimal())


# Define UI for application that draws a histogram
ui <- fluidPage(

        selectInput('selectfile','Select File',choice = list.files('Data/Predicted_flow'))
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  
}

# Run the application 
shinyApp(ui = ui, server = server)

# Global variables can go here
n <- 200

#mydir='C:/Users/garrett.mcgurk/Documents/GitHub/R-Shiny-Apps/Test Apps/CAR-072 Flow App/Data'
  #setwd("mydir")
 in.file= read.csv("C:/Users/garrett.mcgurk/Documents/GitHub/R-Shiny-Apps/Test Apps/CAR-072 Flow App/Data/CAR-072-Flow.csv")
data=in.file
# Define the UI
ui <- bootstrapPage(
  #numericInput('n', 'Number of obs', n),
  plotOutput('plot')
)


# Define the server code
server <- function(input, output) {
 data=ts(data)
   output$plot <- renderPlot({
    plot(input$data)
  })
}

# Return a Shiny app object
shinyApp(ui = ui, server = server)
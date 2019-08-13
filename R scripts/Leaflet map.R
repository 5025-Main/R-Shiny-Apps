install.packages("leaflet")
library(leaflet)
library(readxl)
X2019_MS4_Sites <- read_excel("C:/Users/garrett.mcgurk/Desktop/2019_MS4 Sites.xlsx")

sites.2019= X2019_MS4_Sites [c(9,14)]
sites.2019=as.data.frame(sites.2019)

sites.2019$lng=sapply(strsplit(sites.2019$`ns1:coordinates`,","),"[",1)
sites.2019$lat=sapply(strsplit(sites.2019$`ns1:coordinates`,","),"[",2)

sites.2019$lng=as.numeric(sites.2019$lng)
sites.2019$lat=as.numeric(sites.2019$lat)

class(sites.2019$lng)


m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addCircles(sites.2019,lat = ~ Lat, lng = ~ Lng)
m  # Print the map


leaflet(sites.2019) %>%addTiles() %>% addCircles()

m <- leaflet() %>%
  addTiles() %>%
addMarkers(sites.2019$lng,sites.2019$lat, label = sites.2019$`ns1:name3`) 
m

center <- reactive({
  subset(data, nom == input$canton) 
  # or whatever operation is needed to transform the selection 
  # to an object that contains lat and long
})

site.yo="CAR-070"
site.subset=sites.2019[grep(site.yo, sites.2019$`ns1:name3`),]

site.subset[1,]
subset(sites.2019, )

?subset
??nom

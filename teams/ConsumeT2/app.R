#' @author : François Sémécurbe, Nicolas Chareyre, Saïd Khadraoui, 
#'           Arnaud Degorre, Farida Marouchi


#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(SPARQL)
options(encoding = "UTF-8")



querySiren <-  function(lat, long, dist){ 
  # print(paste0("lat : ", lat))
  # print(paste0("long : ", long))
  endpoint <- "http://hackathon2018-2.ontotext.com/repositories/full-sirene-35"
  query <- sprintf('
                   PREFIX omgeo: <http://www.ontotext.com/owlim/geo#>
                   PREFIX geo-pos: <http://www.w3.org/2003/01/geo/wgs84_pos#>
                   PREFIX sx: <https://sireneld.io/vocab/sirext#>
                   PREFIX sn: <https://sireneld.io/vocab/sirene#>
                   
                   select * where {
                   ?sirene geo-pos:lat ?lat .
                   ?sirene geo-pos:long ?long .
                   ?sirene sn:APET700 ?apet .
                   ?sirene sx:siret ?numeroSiret .
                   ?sirene omgeo:nearby( %f %f "%s")
                   OPTIONAL{ ?sirene sn:ENSEIGNE ?enseigne}
                   OPTIONAL{ ?sirene sn:L1_DECLAREE ?RS}
                   FILTER (?apet = "1071C" || ?apet = "8520Z" || ?apet = "6419Z" )
                   } LIMIT 1000
                   ' , lat, long, paste0(dist, "km")
  )
  resultBrut <- SPARQL(endpoint,query)
  dataBrut <- resultBrut$results
  return(dataBrut)
}




# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Map of schools, banks and bakeries")
   , h4("Application made by François Sémécurbe, Nicolas Chareyre, Saïd Khadraoui, Arnaud Degorre and Farida Marouchi")

   # Sidebar with a slider input for number of bins 
   , sidebarLayout(
      sidebarPanel(
        sliderInput("rayon",
                     "Rayon :",
                     min = 100,
                     max = 5000,
                     value = 500)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         leafletOutput("carte")
        , h4("Click on map, select your neighborhood")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
    # lattitude <- 
  
   output$carte <- renderLeaflet({
     # validate(need(input$carte_click, FALSE))
     click <- input$carte_click
    if(is.null(click)){
      leaflet() %>%
        addProviderTiles(providers$OpenStreetMap.Mapnik,
                         options = providerTileOptions(noWrap = TRUE))%>% 
        addCircles(lat = 48.817275
                   , lng = 2.2977599
                   , radius = 0)
    }
    else{ 
      data <- querySiren(as.numeric(click$lat)
                         , as.numeric(click$lng)
                         , input$rayon/1000) 
      if(nrow(data) > 0){
     leaflet(data = data) %>%
       addProviderTiles(providers$OpenStreetMap.Mapnik,
                        options = providerTileOptions(noWrap = TRUE))%>% 
       addCircles(lat = as.numeric(click$lat)
                  , lng = as.numeric(click$lng)
                  , radius=input$rayon) %>%
       addMarkers(~long, ~lat, popup = ~as.character(sirene)
                  , label = ~as.character(sirene)
       )
    } else{
      leaflet() %>%
        addProviderTiles(providers$OpenStreetMap.Mapnik,
                         options = providerTileOptions(noWrap = TRUE))%>% 
        addCircles(lat = as.numeric(click$lat), lng = as.numeric(click$lng), radius=input$rayon)
        
    }
    }
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)



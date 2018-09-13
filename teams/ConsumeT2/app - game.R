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
library(leaflet)
library(RColorBrewer)
library(geosphere)
library(opencage)
library(sf)

options(encoding = "UTF-8")

points <- data.frame()
clickButtonReset <- FALSE

#'
findCoordinate <- function(adresse){
  query_adresse = opencage_forward(adresse
                                   , key = "d61aae4ec0d64491ab669fac6755a038"
                                   , countrycode = "FR")
  adresse_mercator = data.frame(lat = as.integer(query_adresse$results$annotations.Mercator.x[1])
                                , lng = as.integer(query_adresse$results$annotations.Mercator.y[1]))
  adresses_wgs84 =st_coordinates(st_transform(st_as_sf(adresse_mercator
                                                       , coords = c("lat","lng")
                                                       , crs = 54004)
                                              ,4326))
  return(adresses_wgs84)
}


calcul_score <- function(data1,data2)
{
  dist = matrix(0,nrow(data1),nrow(data2))
  for (i in 1:nrow(data1))
  {
    for (j in 1:nrow(data2))
    {
      dist[i,j]=distGeo(c(data1[i,1],data1[i,2]),c(data2[j,1],data2[j,2]))
    }
  }
  minimum_mean = mean(apply(dist,1,min))
  score=(exp(-minimum_mean/1000))*100
  return(score)
}

# 88 Avenue Verdier, 92120 Montrouge, France
# Latitude : 48.816241 | Longitude : 2.309179

querySiren <-  function(lat, long, dist, naf){ 
  # print(paste0("lat : ", lat))
  # print(paste0("long : ", long))
  endpoint <- "http://hackathon2018-2.ontotext.com/repositories/full-sirene-35"
  query <- sprintf('
                   PREFIX omgeo: <http://www.ontotext.com/owlim/geo#>
                   PREFIX geo-pos: <http://www.w3.org/2003/01/geo/wgs84_pos#>
                   PREFIX sx: <https://sireneld.io/vocab/sirext#>
                   PREFIX sn: <https://sireneld.io/vocab/sirene#>
                   
                   select * where {
                   ?sirene geo-pos:lat ?latitude .
                   ?sirene geo-pos:long ?longitude .
                   ?sirene sn:APET700 ?apet .
                   ?sirene sx:siret ?numeroSiret .
                   ?sirene omgeo:nearby( %f %f "%s")
                   OPTIONAL{ ?sirene sn:ENSEIGNE ?enseigne}
                   OPTIONAL{ ?sirene sn:L1_DECLAREE ?RS}
                   FILTER (?apet = "%s" )
                   } LIMIT 1000
                   ' , lat, long, paste0(dist, "km"), naf
  )
  resultBrut <- SPARQL(endpoint,query)
  dataBrut <- resultBrut$results
  if(nrow(dataBrut) > 0){
    dataBrut$print <- paste(dataBrut$numeroSiret, " - ", dataBrut$enseigne
                            , " - ", dataBrut$RS, " - ", dataBrut$apet)
    colnames(dataBrut) <- c("sirene", "latitude", "longitude", "apet", "numeroSiret"
                            , "enseigne", "RS", "print")
  }
  return(dataBrut)
}

# test <- querySiren(lat = 48.816241
#              , long = 2.309179
#              , dist = 0.5
#            , naf = "1071C" )

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Do you really know neighborhood ?")
  , h4("Application made by François Sémécurbe, Nicolas Chareyre, Saïd Khadraoui, Arnaud Degorre and Farida Marouchi.")
  # Sidebar with a slider input for number of bins 
  , sidebarLayout(
    sidebarPanel(
      textInput("adresse", "Adresse : ", value = "88 avenue Verdier, Montrouge")
      , selectInput("naf"
                    , "Choice :"
                    , choices = c("bakeries" = "1071C"
                                  ,"schools" = "8520Z"
                                  , "banks" = "6419Z" )
                    , selected = "bakeries")
      , sliderInput("rayon",
                    "Rayon :",
                    min = 100,
                    max = 300,
                    value = 100)
      , actionButton("check", "Check !")
      , actionButton("reset", "Reset")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      verbatimTextOutput("verbatim")
      , leafletOutput("carte")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  datasetInput <- eventReactive(input$check, {
    points
  }, ignoreNULL = FALSE)
  
  resetInput <- eventReactive(input$reset,{
    points <- data.frame()
    # coordinate <- findCoordinate(input$adresse)
    # latitude <- coordinate[2]
    # longitude <- coordinate[1]
    # leaflet() %>%
    #   addProviderTiles(providers$OpenStreetMap.Mapnik,
    #                    options = providerTileOptions(noWrap = TRUE))%>%
    #   addCircles(lat = as.numeric(latitude)
    #              , lng = as.numeric(longitude)
    #              , radius = input$rayon)
    print("Clique bouton reset")
    TRUE
  }, ignoreNULL = FALSE)
  
  output$carte <- renderLeaflet({
    # validate(need(input$carte_click, FALSE))
    
    click <- input$carte_click
    coordinate <- findCoordinate(input$adresse)
    latitude <- coordinate[2]
    longitude <- coordinate[1]
    if(is.null(click)){
      clickButtonReset <- FALSE
      leaflet() %>%
        addProviderTiles(providers$OpenStreetMap.Mapnik,
                         options = providerTileOptions(noWrap = TRUE))%>% 
        addCircles(lat = as.numeric(latitude)
                   , lng = as.numeric(longitude)
                   , radius = input$rayon)
    }
    else{ 
      listePoints <- datasetInput()
      if(nrow(listePoints) == 0){
        clickButtonReset <- FALSE
        points <<- rbind(points, list("latitude" =  as.numeric(click$lat)
                                      , "longitude" = as.numeric(click$lng)))
        colnames(points) <- c("latitude", "longitude")
        leaflet(data = points) %>%
          addProviderTiles(providers$OpenStreetMap.Mapnik,
                           options = providerTileOptions(noWrap = TRUE))%>% 
          addCircles(lat = as.numeric(latitude)
                     , lng = as.numeric(longitude)
                     , radius = input$rayon) %>%
          addMarkers(~longitude, ~latitude )
      } else {
        data <- querySiren(as.numeric(latitude)
                           , as.numeric(longitude)
                           , input$rayon/1000
                           , input$naf)
        if(nrow(data) > 0) data$color <- "green"
        points$color <- "red"
        print <- vector()
        for(i in 1:nrow(points)){
          print <- c(print, paste0("click ", i))
        } 
        points$print <- print
        # print(colnames(points))
        # print(colnames(data))
        if(nrow(data) > 0) {
          dataAll <- rbind(data[, c("latitude", "longitude", "print", "color")]
                         , points[, c("latitude", "longitude", "print", "color")]) 
        } else {
          dataAll <- points[, c("latitude", "longitude", "print", "color")]
        }
        # print(paste0("Couleurs : " , dataAll$color))
        icons <- awesomeIcons(markerColor = dataAll$color)
        leaflet(dataAll) %>% addTiles() %>%
          addCircles(lat = as.numeric(latitude)
                     , lng = as.numeric(longitude)
                     , radius = input$rayon) %>%
          addAwesomeMarkers(~longitude, ~latitude
                            , icon = icons
                            , label = ~as.character(print))
      }
      
      
        
    }
  })
  
  output$verbatim <- renderText({
    listePoints <- datasetInput()
    coordinate <- findCoordinate(input$adresse)
    latitude <- coordinate[2]
    longitude <- coordinate[1]
    data <- querySiren(as.numeric(latitude)
                       , as.numeric(longitude)
                       , input$rayon/1000
                       , input$naf)
    if(nrow(listePoints) > 0){
      print(colnames(listePoints))
      print(colnames(data))
      score <- calcul_score(data1 = listePoints[,c("longitude", "latitude")]
                            , data2 = data[,c("longitude", "latitude")])
      print("Liste des points cliqués")
      print(listePoints)
      paste0("Score : "
             , format(score, digits = 3, nsmall = 0, decimal.mark = "," ) 
             , " / 100")
    }
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)



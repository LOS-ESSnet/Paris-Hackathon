library(shiny)
library(ggplot2)
library(shinydashboard)
library(leaflet)
library(DT)
library(geojsonio)

setwd("D:/n0kreh/Mes Documents/PLOS18/")

#paramétrer la date de début (ici 2009) en fonction de l'input
df_agreg_ze <- read.csv(file = "df_agreg_ze.csv", header = T, stringsAsFactors = F)[df_agreg_ze$annee>2009,2:4]
list_df_ze <- split(df_agreg_ze, df_agreg_ze$ze)

ui <- fluidPage(
  
  # App title ----
  titlePanel("The COG'it-Oh Time Machine"),
  
  
  # Sidebar panel for inputs ----
  sidebarPanel(
    
    
    tags$div(
      HTML("<h2>Input settings</h2>")
    ),
    
    
    fileInput("file1", "Choose CSV File",
              accept = c(
                "text/csv",
                "text/comma-separated-values,text/plain",
                ".csv")),
    
    dateInput('date',
              label = 'geography of the input file: yyyy-mm-dd',
              value = Sys.Date()),
    
    tags$div(
      HTML("<h2>Output settings</h2>")
    ),
    
    dateRangeInput('dateRange',
                   label = 'Date range for the time machine product',
                   start = Sys.Date() - 2, end = Sys.Date() + 2),
  
    
    selectInput("zonage", "zonage:",
                c("Zones d'emploi" = "ze",
                  "Bassins de vie" = "bv",
                  "Aires urbaines" = "au")),
    
    #à ajouter : un bouton qui apparaît quand on choisit le zonage pour choisir le millésime de ce zonage
    
    tags$div(
      HTML("<h2>Displaying Options</h2>")
    ),
    
    radioButtons("granularity", h3("granularity"),
                 choices = list("national evolution" = 1, "local evolution" = 2),
                 selected = 2),
    
    actionButton("goButton", "ERGO SUM!")
  ),
  
  # Main panel for displaying outputs ----
  mainPanel(
    
    downloadButton("downloadData", "Download"),
    
    tags$head(
      tags$style(HTML(".leaflet-container {background: #FFFFFF; }"))
    ),
    
    # Output: 
    #plotOutput(outputId = "distPlot"),
    conditionalPanel('input.granularity==1', plotOutput(outputId = "plotgif"))
    ,
    conditionalPanel('input.granularity==2', column(8,leafletOutput("map", height="600px"))),
    conditionalPanel('input.granularity==2', column(4,br(),br(),br(),br(),plotOutput("plot", height="300px")))

  )
)



################################################################################################
################################################################################################
server <- function(input, output) {
  
  observeEvent(input$goButton, {
    
    output$contents <- renderTable({

      inFile <- input$file1
      
      if (is.null(inFile))
        return(NULL)
    })
    
    output$plotgif <- renderImage({
      
      #à améliorer : que la fonction graphe (du fichier makegif) soit appelée sur le dataset donnée en entrée (et gérer les erreurs si c'est du mauvais csv)
      
      source(paste0(getwd(),"/makegif.R",sep=""))
      g <- graphe(q,9)
      g
      
      list(src = paste0(getwd(),"/ze.gif",sep=""),
           contentType = 'image/gif'
      )}, deleteFile = FALSE)
    
    ze_geojson <- geojsonio::geojson_read("zone_emploi.geojson",
                                          what = "sp")
    
    # Leaflet map
    output$map <- renderLeaflet({

      leaflet(ze_geojson) %>% 
        setView(lng = 2, lat = 47, zoom = 5)  %>%
        addPolygons(stroke = T, color = "#C8AD7F", weight = 3, layerId=~ze_geojson$code, smoothFactor = 0.3, fillOpacity = 0.7,
                    highlight = highlightOptions(weight = 5, color = "#666", fillOpacity = 0.5,
                                                 bringToFront = TRUE))
      
    })
    
    # create a reactive value that will store the click position
    data_of_click <- reactiveValues(clickedMarker=NULL)
    
    # store the click
    observeEvent(input$map_shape_click,{
      data_of_click$clickedShape <- input$map_shape_click
    })
    
    # Make a scatterplot depending of the selected point
    output$plot=renderPlot({

      ze_click = data_of_click$clickedShape$id
      if(is.null(ze_click)){ze_click = "empty"}
      
      if(ze_click %in% as.numeric(names(list_df_ze))){
        df_ze_click <- list_df_ze[[as.character(ze_click)]]
        plot(df_ze_click$annee,df_ze_click$count, xlab = "Année", ylab = "Nombre d'entreprise créées")
        
      }else{
        plot.new
      }   
    })
    
    #à ajouter : le bouton download doit récupérer l'output de la fonction d'aggrégation
    
  })
  
}



shinyApp(ui = ui, server = server)

###################################################################################################
#               Linked Open Statistics Hackathon - Paris, september 2018                          #
#                                                                                                 #
#     R-Shiny demo with SPARQL Query on data endpoints and visualisations                         #
#                         Work in progress, v0.8 - 2018-09-05                                     #
#                                                                                                 #
#     This light R-Shiny app has been designed as preliminary work to test basic queries on       #
#     linked opened data and help discovering various way to access and use RDF datasets.         #
#     Access to RDF data is embedded in a R-Shiny App, which main objective is to illustrate      #
#     basic use of RDF data downloaded and structured through SPARQL queries                      #
#                                                                                                 #
###################################################################################################

library(shiny)
library(SPARQL)
library(RColorBrewer)
library(tmap)
library(leaflet)
library(tidyr)
library(sp)
library(treemap)
library(dplyr)


options(encoding = "UTF-8")


### Start of server side ###
server <- function(input, output) 
{

  ###########################
  # Parameters for Treemap 1
  ###########################
  
  observeEvent(input$v_code_county_1,{

  endpoint1 <- "http://rdf.insee.fr/sparql"
  
  q1 <-
    sprintf("
            PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
            PREFIX igeo:<http://rdf.insee.fr/def/geo#> 
            PREFIX idemo:<http://rdf.insee.fr/def/demo#> 
            
            SELECT DISTINCT ?codeINSEE ?codeCommune ?nomVille ?popTotale2010 ?popTotale2014 where { 
            ?ville rdf:type igeo:Commune ; idemo:population ?population2014 ; idemo:population ?population2010 .
            ?ville igeo:subdivisionDe ?arrondissement . 
            ?arrondissement igeo:subdivisionDe ?dpt . 
            ?ville igeo:nom ?nomVille . 
            ?ville igeo:codeCommune ?codeCommune .
            ?ville igeo:codeINSEE ?codeINSEE .
            ?dpt igeo:codeDepartement '%s'^^xsd:token .
            ?population2010 idemo:date '2010-01-01'^^<http://www.w3.org/2001/XMLSchema#date> ; idemo:populationTotale ?popTotale2010 . 
            ?population2014 idemo:date '2014-01-01'^^<http://www.w3.org/2001/XMLSchema#date> ; idemo:populationTotale ?popTotale2014 . 
            
            } 
            ",input$v_code_county_1)
  
  result_1 <- SPARQL(url=endpoint1, query=q1)$results
  
  output$plot1 <- renderPlot({
    
    result_1$commune_taille <- ""
    result_1$commune_taille <- ifelse(result_1$popTotale2014 >= 50000,"> 50 000",result_1$commune_taille) 
    result_1$commune_taille <- ifelse(result_1$popTotale2014 < 50000 & result_1$popTotale2014 >= 20000,"20 000-50 000",result_1$commune_taille) 
    result_1$commune_taille <- ifelse(result_1$popTotale2014 < 20000 & result_1$popTotale2014 >= 10000,"10 000-20 000",result_1$commune_taille) 
    result_1$commune_taille <- ifelse(result_1$popTotale2014 < 10000 & result_1$popTotale2014 >= 5000,"5 000-10 000",result_1$commune_taille) 
    result_1$commune_taille <- ifelse(result_1$popTotale2014 < 5000 & result_1$popTotale2014 >= 2000,"2 000-5 000",result_1$commune_taille) 
    result_1$commune_taille <- ifelse(result_1$popTotale2014 < 2000,"< 2 000",result_1$commune_taille) 
    
    library(dplyr)

    database_treemap <- result_1 %>%
      group_by(commune_taille) %>%
      summarise(SumPopTotale2010 = sum(popTotale2010),SumPopTotale2014 = sum(popTotale2014))
    
    database_treemap$evolution_2010_2014 <- 100*(database_treemap$SumPopTotale2014 - database_treemap$SumPopTotale2010)/database_treemap$SumPopTotale2010
    
    library(treemap)
    tm <- treemap(database_treemap,
                  index=c('commune_taille'),
                  vSize='SumPopTotale2014',
                  vColor='evolution_2010_2014',
                  title=paste0("Total population per city size for department ",input$v_code_county_1," and percentage change between 2010 and 2014"),
                  type="manual",
                  palette=rev(brewer.pal(5,"RdYlBu")),
                  border.col= c("white","black"),
                  border.lwds=c(5,1),
                  align.labels=list(c("left","top"),c("right","bottom")))
    
  })
  
  })
  
  
  ###########################
  # Parameters for Treemap 2
  ###########################
  
  observeEvent(input$v_code_county_2,{
    
    endpoint2 <- "http://rdf.insee.fr/sparql"
    
    q2 <-
      sprintf("
              PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
              PREFIX igeo:<http://rdf.insee.fr/def/geo#> 
              PREFIX idemo:<http://rdf.insee.fr/def/demo#> 
              
              SELECT DISTINCT ?codeINSEE ?codeCommune ?nomVille ?popTotale2010 ?popTotale2014 where { 
              ?ville rdf:type igeo:Commune ; idemo:population ?population2014 ; idemo:population ?population2010 .
              ?ville igeo:subdivisionDe ?arrondissement . 
              ?arrondissement igeo:subdivisionDe ?dpt . 
              ?ville igeo:nom ?nomVille . 
              ?ville igeo:codeCommune ?codeCommune .
              ?ville igeo:codeINSEE ?codeINSEE .
              ?dpt igeo:codeDepartement '%s'^^xsd:token .
              ?population2010 idemo:date '2010-01-01'^^<http://www.w3.org/2001/XMLSchema#date> ; idemo:populationTotale ?popTotale2010 . 
              ?population2014 idemo:date '2014-01-01'^^<http://www.w3.org/2001/XMLSchema#date> ; idemo:populationTotale ?popTotale2014 . 
              
              } 
              ",input$v_code_county_2)
    
    result_2 <- SPARQL(url=endpoint2, query=q2)$results
    
    output$plot2 <- renderPlot({
      
      result_2$commune_taille <- ""
      result_2$commune_taille <- ifelse(result_2$popTotale2014 >= 50000,"> 50 000",result_2$commune_taille) 
      result_2$commune_taille <- ifelse(result_2$popTotale2014 < 50000 & result_2$popTotale2014 >= 20000,"20 000-50 000",result_2$commune_taille) 
      result_2$commune_taille <- ifelse(result_2$popTotale2014 < 20000 & result_2$popTotale2014 >= 10000,"10 000-20 000",result_2$commune_taille) 
      result_2$commune_taille <- ifelse(result_2$popTotale2014 < 10000 & result_2$popTotale2014 >= 5000,"5 000-10 000",result_2$commune_taille) 
      result_2$commune_taille <- ifelse(result_2$popTotale2014 < 5000 & result_2$popTotale2014 >= 2000,"2 000-5 000",result_2$commune_taille) 
      result_2$commune_taille <- ifelse(result_2$popTotale2014 < 2000,"< 2 000",result_2$commune_taille) 
      
      library(dplyr)

      database_treemap <- result_2 %>%
        group_by(commune_taille) %>%
        summarise(SumPopTotale2010 = sum(popTotale2010),SumPopTotale2014 = sum(popTotale2014))
      
      database_treemap$evolution_2010_2014 <- 100*(database_treemap$SumPopTotale2014 - database_treemap$SumPopTotale2010)/database_treemap$SumPopTotale2010
      
      library(treemap)
      tm <- treemap(database_treemap,
                    index=c('commune_taille'),
                    vSize='SumPopTotale2014',
                    vColor='evolution_2010_2014',
                    title=paste0("Total population per city size for department ",input$v_code_county_2," and percentage change between 2010 and 2014"),
                    type="manual",
                    palette=rev(brewer.pal(5,"RdYlBu")),
                    border.col= c("white","black"),
                    border.lwds=c(5,1),
                    align.labels=list(c("left","top"),c("right","bottom")))
      
    })
  
  
  })
  
  
  ###########################
  # Parameters for Mapping application
  ###########################
  
  # Part 1 - downloading spatial data and building area's boundaries through Multipolygons data
  library(SPARQL)
  endpoint3 <- "http://graphdb.linked-open-statistics.org/repositories/nuts"

  q3 <-"
  PREFIX owl: <http://www.w3.org/2002/07/owl#>
  PREFIX igeo:<http://rdf.insee.fr/def/geo#>
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX geo: <http://www.opengis.net/ont/geosparql#>
  select ?code ?name ?contours where {
  ?zone owl:sameAs ?dep .
  SERVICE <http://id.insee.fr/sparql> {
  ?dep rdf:type igeo:Departement .
  ?dep igeo:nom ?name .
  ?dep igeo:codeINSEE ?code .
  }
  ?zone geo:hasGeometry ?geometry .
  ?geometry geo:asWKT ?contours .
  }
  ORDER BY ?code
  "

  result_map <- SPARQL(url=endpoint3, query=q3)$results
  result_map <- result_map[grepl("2A|2B|971|972|973|974|975|976", result_map$code)!=T,]
  result_map$code <- substr(result_map$code,2,3)

  result_map <- result_map[order(result_map$code),]

  
  ########### MOD############
  v_list_codedept <- reactiveValues()
  v_list_codedept <- result_map$code
  
  output$v_code_county_1 = renderUI({
    selectInput("v_code_county_1",label="Choose county code 1",c("Select code",v_list_codedept),selected=83,selectize = TRUE,width="100%")
  })
  
  output$v_code_county_2 = renderUI({
    selectInput("v_code_county_2",label="Choose county code 2",c("Select code",v_list_codedept),selected=59,selectize = TRUE,width="100%")
  })
  ###########################
  
  
  print("Spatial polygons loaded")

  # Part 2 - Demographic data, to be merged to spatial data so as to get SpatialPolygonDataFrame
  # This query will also be used for SnailViz panel (see below)
  library(SPARQL)
  endpoint4 <- "http://graphdb.linked-open-statistics.org/repositories/pop5"

  q4 <-
    "
  PREFIX qb: <http://purl.org/linked-data/cube#>
  PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
  select ?code ?label ?sexe ?age (sum(?pop) as ?popTot) where {
  ?s a qb:Observation ;
  qb:dataSet ?dataset .
  ?s <http://id.insee.fr/meta/dimension/sexe> ?sexe .
  ?s <http://id.insee.fr/meta/dimension/ageq65> ?age .
  ?s <http://id.insee.fr/meta/mesure/pop15Plus> ?pop .
  ?s <http://id.insee.fr/meta/cog2017/dimension/DepartementOuCommuneOuArrondissementMunicipal> ?area .
  ?area skos:topConceptOf <http://id.insee.fr/codes/cog2017/departementsOuCommunesOuArrondissementsMunicipaux>.
  ?area skos:prefLabel ?label .
  ?area skos:notation ?code .
  }
  GROUP BY ?code ?label ?sexe ?age
  ORDER BY ?code
  "

  stat_pop <- SPARQL(url=endpoint4, query=q4)$results
  
  # Some recoding of variable labels
  stat_pop$sexe <- gsub("<http://id.insee.fr/codes/sexe/","S",stat_pop$sexe)
  stat_pop$sexe <- gsub(">","",stat_pop$sexe)
  stat_pop$age <- gsub("<http://id.insee.fr/codes/ageq65/0","A",stat_pop$age)
  stat_pop$age <- gsub(">","",stat_pop$age)
  stat_pop$key <- paste0(stat_pop$sexe,stat_pop$age)
  stat_pop[,c("sexe","age")] <- NULL
  
  library(tidyr)
  stat_pop <- stat_pop %>%  spread(key, popTot)

  stat_pop$SXAXX <- apply(stat_pop[,c(3:ncol(stat_pop))], 1, sum)
  stat_pop$S1AXX <- apply(stat_pop[,c(3:13)], 1, sum)
  stat_pop$S2AXX <- apply(stat_pop[,c(14:24)], 1, sum)

  stat_pop <- stat_pop[stat_pop$code %in% v_list_codedept,]
  
  stat_pop$label <- gsub("@fr","",stat_pop$label)
  

  # From Nuts geographic data, here we produce spatial polygons (geo. boundaries)
  
  # we first convert variable result$contours (which is WellKnownText string) as an appropriate sp geometry object
  # SP gives R Classes and Methods for Spatial Data
  # We use rgeos library and function readWKT to convert data
  library(rgeos)
  g <- lapply(substr(result_map$contours,2, nchar(result_map$contours)),readWKT)
  
  for (i in c(1:length(g)))
  { g[[i]]@polygons[1][[1]]@ID <- v_list_codedept[i] }
  
  # SpatialPolygons is an SP function creating objects of class SpatialPolygons or SpatialPolygonsDataFrame
  # from lists of Polygons objects and data.frames
  map_polygons = SpatialPolygons(lapply(g, function(x){x@polygons[[1]]}))
  
  # fakedata <- data.frame( ID=1:length(map_polygons), growth=runif(length(map_polygons)))
  
  # Fixing rownames of statistical dataframe equal to IDs of spatial polygons.
  # Check : rownames and stat_pop$code should be identical, otherwise merging would be biased.
  rownames(stat_pop) <- sapply(slot(map_polygons, "polygons"), function(x) slot(x, "ID"))
  
  # Merging Spatial data et Statistical data into a SpatialPolygonsDataFrame
  map_polygons_df <- SpatialPolygonsDataFrame(map_polygons, stat_pop)
  
  
  # Here start the reactive part, producing a map given user's parameters

  observe({
    
    # We create new data inside the SpatialPolygonsDataFrame
    map_polygons_df@data$value <- ( eval(parse(text=paste0("map_polygons_df@data$S1A", input$v_code_panel2_variable1))) + eval(parse(text=paste0("map_polygons_df@data$S2A", input$v_code_panel2_variable1))) ) / ( eval(parse(text=paste0("map_polygons_df@data$S1A", input$v_code_panel2_variable2))) + eval(parse(text=paste0("map_polygons_df@data$S2A", input$v_code_panel2_variable2))) )
    
    library(sf)
    # Here we choose boundings for plotting map
    box_region = st_bbox(c(xmin = -5, xmax = 10, ymin = 40, ymax = 52))
    
    output$map1 = renderLeaflet({
      
      map1 <- tm_shape(map_polygons_df, bbox = tmaptools::bb(box_region)) +
        tm_polygons("value", style="quantile", title="Ageing ratio", palette = "-RdBu") +
        tm_bubbles(size = paste0("S1A",input$v_code_panel3_variable2), col = "green",
                   border.col = "black", border.alpha = 0.5, legend.size.show = TRUE, legend.col.show = TRUE) +
        tm_layout(paste0("Ratio of ",input$v_code_panel2_variable1," and ",input$v_code_panel2_variable2," years old by region"),
                  legend.title.size = 1,
                  legend.text.size = 0.6,
                  legend.position = c("left","bottom"),
                  legend.bg.color = "white",
                  legend.bg.alpha = 1) 
      
      tmap_leaflet(map1)
      
    })
    
    
  })
  
  ################################
  # Producing a SnailViz (circular barplot)
  ###############################
  
  
  # Here start the reactive part, being updated given user's choice on age categories
  
  
  observe({
  
  stat_pop$value <- ( eval(parse(text=paste0("stat_pop$S1A", input$v_code_panel3_variable1))) + eval(parse(text=paste0("stat_pop$S2A", input$v_code_panel3_variable1))) ) / ( eval(parse(text=paste0("stat_pop$S1A", input$v_code_panel3_variable2))) + eval(parse(text=paste0("stat_pop$S2A", input$v_code_panel3_variable2))) )
  value_mean <- sum( eval(parse(text=paste0("stat_pop$S1A", input$v_code_panel3_variable1))) + eval(parse(text=paste0("stat_pop$S2A", input$v_code_panel3_variable1))) ) / sum( eval(parse(text=paste0("stat_pop$S1A", input$v_code_panel3_variable2))) + eval(parse(text=paste0("stat_pop$S2A", input$v_code_panel3_variable2))) )
  stat_pop$group <- ifelse(stat_pop$value > value_mean,"Older regions","Younger regions")
  
  if (input$v_code_panel3_order == "YES"){
    stat_pop_graph <- stat_pop %>% arrange(group,value)
  } else {
    stat_pop_graph <- stat_pop
  }
  
  
  # stat_pop <- stat_pop[order(-stat_pop$ratio_SXA65_SXA25),]
  stat_pop_graph$id <- seq(1,nrow(stat_pop_graph))
  
  # stat_pop$id <- as.character(1:nrow(stat_pop))
  # row.names(stat_pop) <- 1:nrow(stat_pop)
  
  # ----- This section prepare a dataframe for labels ---- #
  # Get the name and the y position of each label
  label_data=stat_pop_graph
  
  # calculate the ANGLE of the labels
  number_of_bar=nrow(label_data)
  # label_data$id = 1:nrow(label_data)
  angle= 90 - 360 * (label_data$id-0.5) /number_of_bar     
  
  # calculate the alignment of labels: right or left
  # If I am on the left part of the plot, my labels have currently an angle < -90
  label_data$hjust<-ifelse( angle < -90, 1, 0)
  
  # flip angle BY to make them readable
  label_data$angle<-ifelse(angle < -90, angle+180, angle)
  # ----- ------------------------------------------- ---- #
  
  output$SnailViz <- renderPlot({
  
  library(ggplot2)
  # Make the plot
  SnailViz = ggplot(stat_pop_graph, aes(x=id, y=value, fill=group)) +       
    # Note that id is a factor. If x is numeric, there is some space between the first bar
    
    # This add the bars with a blue color
    geom_bar(stat="identity", alpha=0.5) +
    
    # Limits of the plot = very important. The negative value controls the size of the inner circle, the positive one is useful to add size over each bar
    ylim(-20,20) +
    
    # Custom the theme: no axis title and no cartesian grid
    theme_minimal() +
    theme(
      axis.text = element_blank(),
      axis.title = element_blank(),
      panel.grid = element_blank(),
      plot.margin = unit(rep(-2,4), "cm")     # This remove unnecessary margin around plot
    ) +
    
    # This makes the coordinate polar instead of cartesian.
    coord_polar(start = 0) +
    
    # Add the labels, using the label_data dataframe that we have created before
    geom_text(data=label_data, aes(x=id, y=value+2, label=paste(code,label), hjust=hjust), color="black", fontface="bold",alpha=0.6, size=3, angle= label_data$angle, inherit.aes = FALSE )
  
  SnailViz
  
  })
  
  
  })
  
  
}
### End of server side ###


ui <- fluidPage(
  navbarPage(title="Linked Open Stats - R-Shiny Demo - Population and cities ",
             tabPanel(title="Contents",
                      fluidRow(
                        column(6,offset=3,tags$div(HTML("<h3><b><left> Main purpose - RDF, SPARQL and R-Shiny </left></b></h3>")))
                      ),
                      fluidRow(
                        column(6,offset=3,tags$div(HTML("<h4>This light R-Shiny app has been designed to test basic queries of linked opened data and help discovering various way to access and use RDF datasets. Data are stored either as standalone RDF files or through online SPARQL endpoints. With no previous knowledge on web semantics, the preliminary step before starting the build of our Shiny App was to understand the way RDF datasets work, including basic comprehension of triplets structure and graphes, serialization and textual syntaxes like <I>turtle</I>, or the use of ontologies as generalised and linked metadata. Next we got some documentation on SPARQL language as semantic query language, with main query variations. Access to RDF data is embedded in a R-Shiny App, which main objective is to illustrate basic use of RDF data downloaded and structured through SPARQL Query. We also test building of geospatial data (both spatial polygons so as to draw boundaries and statistical data to be used in cloropleth maps). R packages being used are SPARQL for RDF query, tmap, sp and leaflet for maps, dplyr and tidyr for data reshaping, treemap and ggplots for dataviz </h4>")))
                      ),
                      fluidRow(
                        column(6,offset=3,tags$div(HTML("<h4>Regarding data, we focus on demographic and geographic datasets, namely French census dataset and geographical codes from INSEE, and spatial datasets giving geospatial layers and boundaries. Our statistical purpose is to analyse demographic trends across French regions and how population is distributed between big and small cities - that is to say, how cities sum up as <I>bricks</I> in different ways depending on urbanization degree, and how demographic concentration has been strengthened or not in recent years. <br><br> We also have a look on ageing tendencies, checking our hypothesis of a greater pace of demographic concentration for young adults in biggest cities than for other age categories. Our view would be that young adults (20-30 years old) are guided by economic factors, either about educational facilities (universities) or job opportunies, that are both inequally implemented across cities (and highly centralized), while older adults (above 30 years old) and particularly families may be located given environmental factors and life-quality aspects, albeit still linked to job location not being too far from residential area.  </h4>")))
                      ),
                      tags$br(),
                      HTML('<center><img border="0" src="http://www.w3.org/RDF/icons/rdf_w3c_icon.128" alt="RDF Resource Description Framework Icon"/></center>')
                      ),
             tabPanel(title="1 - BrickCities",
                      fluidRow(
                        column(8,offset=2,tags$div(HTML("<h5> <I><center> Due to downloading time (and poor quality code :-| ), figures may take some time to show up </center></I></h5>")))
                      ),
                      fluidRow(
                        column(3,offset=1,htmlOutput("v_code_county_1")),
                        column(3,offset=3,htmlOutput("v_code_county_2"))
                        ),
                      fluidRow(
                        column(5,offset=0,plotOutput("plot1",height=450)),
                        column(5,offset=2,plotOutput("plot2",height=450))
                      )
             ),
             tabPanel(title="2 - Maps",
                      fluidRow(
                        column(8,offset=2,tags$div(HTML("<h5> <I><center> Due to downloading time (and poor quality code :-| ), figures may take some time to show up </center></I></h5>")))
                      ),
                      fluidRow(
                        column(3,offset=2,selectInput('v_code_panel2_variable1',label="Choose age category 1",choices= c(15,20,25,30,35,40,45,50,55,60,65),selected=65)),
                        column(3,offset=2,selectInput('v_code_panel2_variable2',label="Choose age category 2",choices= c(15,20,25,30,35,40,45,50,55,60,65),selected=25))
                      ),
                      fluidRow(
                        column(6,offset=3,leafletOutput("map1", height=800))
                      )
                    ),
             tabPanel(title="3 - SnailViz",
                      fluidRow(
                        column(8,offset=2,tags$div(HTML("<h5> <I><center> Due to downloading time (and poor quality code :-| ), figures may take some time to show up </center></I></h5>")))
                      ),
                      fluidRow(
                        column(3,offset=1,selectInput('v_code_panel3_variable1',label="Choose age category 1 (numerator)",choices= c(15,20,25,30,35,40,45,50,55,60,65),selected=65)),
                        column(3,offset=1,selectInput('v_code_panel3_variable2',label="Choose age category 2 (denominator)",choices= c(15,20,25,30,35,40,45,50,55,60,65),selected=25)),
                        column(3,offset=1,selectInput('v_code_panel3_order',label="Ordering results ?",choices= c("YES","NO"),selected="YES"))
                        
                      ),
                      fluidRow(
                        column(8,offset=2,plotOutput("SnailViz",height=700))
                      )
                    )
             )
  )

             

shinyApp(ui = ui, server = server)


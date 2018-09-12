library(SPARQL)
library(dplyr)
library(leaflet)


querySiren <-  function(lat, long, dist){ 
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


baseBrut <- querySiren(48.816363, 2.317384, 0.3)

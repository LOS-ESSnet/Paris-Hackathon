import csv

prefixe_url_siren = "https://api.insee.fr/siret/"

predicate_name = "rdfs:label"
predicate_long = "sx:longitude"
predicate_lat = "sx:latitude"
predicate_purpose = "org:purpose"

SIREN = "SIREN"
NIC = "NIC"
APEN = "APEN700"
NOMEN_LONG = "NOMEN_LONG"
LOGITUDE = "longitude"
latitude = "latitude"
prefix_siret = "https://api.insee.fr/entreprises/sirene/siret/"

prefix_ape = "http://id.insee.fr/codes/nafr2/sousClasse/";

def addChevrons( string ):
   return "<" + string + ">"

def create_line_string( predicate, object ):
   return "\t" + predicate + " \"" + object.replace('"','')  + "\" ; \n"

def create_line_url( predicate, object ):
   return "\t" + predicate + addChevrons(object.replace('"',''))  + " ; \n"


def create_point(siret, lat, long):
    pointName = "%sPoint"%(siret)
    point ="\tgeo:hasGeometry ex:%s .\n"%(pointName)
    point += "ex:%s a sf:Point;\n"%(pointName)
    point += "\tgeo:asWKT \"POINT(%s %s)\"^^geo:wktLiteral.\n"%(long, lat)
    return point
    

#with open('geo-sirene_rdf.ttl', 'w') as output:

with open('geo-sirene_35_rdf.ttl', 'w', encoding="utf8") as output:
#on écrit les prefixe
    output.write("@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema> .\n")
    output.write("@prefix  sx: <http://www.w3.org/2003/01/geo/wgs84_pos> .\n")
    output.write("@prefix  xsd: <http://www.w3.org/2001/XMLSchema#> .\n")
    output.write("@prefix  rdf:<https://www.w3.org/1999/02/22-rdf-syntax-ns> .\n")
    output.write("@prefix  geo: <http://www.opengis.net/ont/geosparql#> .\n")
    output.write("@prefix  ex: <http://www.example.org/POI#> .\n")
    output.write("@prefix  sf: <http://www.opengis.net/ont/sf#> .\n")
    output.write("@prefix  org: <http://www.w3.org/ns/org#> .\n")
                

    
    #with open('geo_sirene.csv', 'r', encoding="utf8") as csvfile:
    with open('geo-sirene_35.csv', 'r', encoding="utf8") as csvfile:
        csvreader = csv.reader(csvfile, delimiter=',', quotechar='"')
        # tableau de résultat
    
        headers = next(csvreader)
        
        indice_SIREN =  headers.index(SIREN)
        indice_NIC =  headers.index(NIC)
        indice_NOMEN_LONG =  headers.index(NOMEN_LONG)
        indice_LOGITUDE =  headers.index(LOGITUDE)
        indice_latitude =  headers.index(latitude)
        indice_APEN =  headers.index(APEN)
    
        i=0
        for row in csvreader:
            siret = row[indice_SIREN]+row[indice_NIC]
            output.write(addChevrons(prefix_siret+siret)+"\n")
            output.write("\trdf:type org:OrganizationalUnit ;\n ")
            
            better_apen = row[indice_APEN][:2]+"."+row[indice_APEN][2:]
            output.write(create_line_string(predicate_name,row[indice_NOMEN_LONG]))
            output.write(create_line_url(predicate_purpose,prefix_ape+better_apen))
            output.write(create_point(siret, row[indice_latitude], row[indice_LOGITUDE] ))
            
            i+=1
            
            if (i%100==0):
                print(i)
            
            
        

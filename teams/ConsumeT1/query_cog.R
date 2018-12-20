createSPARQLdata=function(){
library("SPARQL")
url="http://id.insee.fr/sparql/"

query="PREFIX idemo:<http://rdf.insee.fr/def/demo#>
PREFIX igeo:<http://rdf.insee.fr/def/geo#>
PREFIX syntax:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>

SELECT  (str(?commune_depart1) as ?ID_COMMUNE) (str(?date1) as ?DATE_EFF) (str(?commune1) as ?ID_COMMUNE_ECH) (str(?idMvt) as ?id_mvt) WHERE {
  ?s igeo:mouvementTerritoire ?commune_depart0.
  ?s igeo:valeurApresCreation ?commune0 .
  ?commune0 a ?t1.
  ?t1 rdfs:subClassOf igeo:CommuneOuAssimilee.
  ?commune_depart0 a ?t2.
  ?t2 rdfs:subClassOf igeo:CommuneOuAssimilee.
  ?s syntax:type igeo:Creation.
  ?s igeo:mouvementPropriete igeo:subdivisionDe.
  ?s igeo:referenceMouvementBase ?idMvt.
  ?idMvt igeo:dateEffet ?date1 .
  ?commune0 igeo:codeINSEE ?commune1.
  ?commune_depart0 igeo:codeINSEE ?commune_depart1.
  Filter(?commune_depart0 != ?commune0).
}"
d=data.frame(SPARQL(url = url, query= query)$results)
return(d)
}



explore=function(forceSPARQL=FALSE){
  if(forceSPARQL || ! exists("mouvementsHackfusions")){
    mouvementsHackfusions<<-createSPARQLdata()
  }
  #mouvementsHackfusions <- read.csv("C:/Users/nirnfv/Desktop/mouvementsHackfusions.csv", sep=";", stringsAsFactors=FALSE)
#res0=aggregate(formula(ID_COMMUNE~id_mvt+DATE_EFF+ID_COMMUNE_ECH+modbis), data=mouvementsHackfusions, subset=mouvementsHackfusions$modbis==0 & as.character(mouvementsHackfusions$MOD) != "com500" & as.character(mouvementsHackfusions$MOD) != "com700",FUN=function(x){x});
  res=aggregate(formula(ID_COMMUNE~id_mvt+DATE_EFF+ID_COMMUNE_ECH), data=mouvementsHackfusions,FUN=function(x){x});
  #res1=aggregate(formula(ID_COMMUNE_ECH~id_mvt+DATE_EFF+ID_COMMUNE+modbis), data=mouvementsHackfusions, subset=mouvementsHackfusions$modbis==1,FUN=function(x){x});
#res0bis=res0[,c("DATE_EFF","ID_COMMUNE","ID_COMMUNE_ECH","id_mvt","modbis")];
#res1bis=res1[,c("DATE_EFF","ID_COMMUNE","ID_COMMUNE_ECH","id_mvt","modbis")];
#res=rbind(res0bis,res1bis)
score=aggregate(x=rep(1,nrow(res)),by=list(res$ID_COMMUNE_ECH),FUN=length)
#score1=aggregate(x=rep(1,nrow(res[res$modbis==1,])),by=list(res$ID_COMMUNE_ECH[res$modbis==1]),FUN=length)
names(score)=c("COMMUNE","score")
#names(score1)=c("COMMUNE","score1")
#score=merge(score0,score1,all=TRUE)
score$enfants=NA
#score$enfants_tout=NA
#score$enfants_score=NA
score$niveau=0
#score$enfants_score1=NA
for(i in seq(len=nrow(score))){
  ind_i = res$ID_COMMUNE_ECH==score[i,"COMMUNE"]
  liste_enfants=res[ind_i,c("ID_COMMUNE","DATE_EFF")]
  #browser()
  #browser()
  #if(length(liste_enfants)>1){
  #  browser()
  #}
  #score$enfants_score[i]=sum(score$score[score$COMMUNE %in% liste_enfants],na.rm=TRUE)

  #score$enfants_score1[i]=sum(score$score1[score$COMMUNE %in% liste_enfants],na.rm=TRUE)
  score$enfants[i]=list(liste_enfants)
}

# for(i in seq(len=nrow(score))){
#   liste_enfants=unlist(score$enfants[i])
#   if(score$enfants_score[i]>0){
#   score$enfants_tout[i]=score$enfants[i]
#   ind = which(score$COMMUNE %in% liste_enfants)
#   for(j in ind ){
#     if( ! is.na(score$enfants_tout[j])){
#        score$enfants_tout[i]=list(c(unlist(score$enfants_tout[i]),unlist(score$enfants_tout[j])))
#     }
#    
#   }
#   score$niveau[i]=score$niveau[i]+1
# }
# }

modif=TRUE
#browser()
while(modif){
  #print(paste(c("HELLO",modif)))
  modif=FALSE
  for(i in seq(len=nrow(score))){
  
  if( ! is.na(score$enfants[i])){
    
     a=score$enfants[i][[1]]
     n0=nrow(a)
     #browser()
    ind = which(score$COMMUNE %in% a$ID_COMMUNE)
   
    #print(a$ID_COMMUNE)
    for(j in ind ){
      #if( ! is.na(score$enfants[j][[1]])){
        a=(rbind(a,score$enfants[j][[1]]))
        #print(i)
       # }
    }
    b=unique(a)
    
    if(nrow(b) != n0 ){
      score$enfants[i]=list(b)
      #print(i)
      score$niveau[i]=score$niveau[i]+1
      modif=TRUE
    }
    
  }
}
}
#browser()
#score_res=score$COMMUNE[score$score==1 & score$enfants_score==0]
#browser()
#res_plus=merge(res,score,by.x="ID_COMMUNE_ECH",by.y="COMMUNE")
#res_simple=res[res$ID_COMMUNE_ECH %in% score_res,]
#res_complexe=res[ ! res$ID_COMMUNE_ECH %in% score_res,]
return(score)

}
histoireCommune=function(commune,date){
  if(! exists("base_fondamentale_hack")){
    base_fondamentale_hack<<-explore(forceSPARQL = FALSE)
  }
  ind=which(base_fondamentale_hack$COMMUNE==as.character(commune))
  res=as.character(commune)
  if(is.null(ind)){
    return(res)
  } else if(length(ind)==1){
    base=base_fondamentale_hack[ind,"enfants"][[1]]
    dates=as.Date(base$DATE_EFF)
    date0=as.Date(date)
    ind1=dates>=date0
    res=c(res,as.character(base$ID_COMMUNE[ind1]))
    return(res)
  } else {
    stop("Aaaaaaaaaaaaaaaaaaaaaaaaaaaaarrrrrrrrrrrrrrrrrrrrgh")
  }
  
}
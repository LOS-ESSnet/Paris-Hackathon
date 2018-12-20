#fichiers images 
library(magick)
library(cartography)
library(rgdal)

setwd("D:/n0kreh/Mes Documents/PLOS18/")

graphe=function(base,nb_annee){
  carte_ze <- readOGR(paste0(getwd(),"/z10_francemetro_2017.shp",sep=""))
  rep=paste0(getwd(),"/images gif",sep="")
  
  cols <- carto.pal(pal1 = "orange.pal", n1 = 6,middle = TRUE)
  fdim <- getFigDim(x = carte_ze, 
                    width = 750, res = 130,
                    mar = c(0,0,1.2,0))
  
  #à améliorer : que le nombre d'année soit bien pris comme le paramètre donné dans l'interface shiny
  #à améliorer : que le fichier "base" soit celui issue de la requête sparql et de l'aggrégation
  
  nom=names(base)
  for (i in 2:nb_annee+1) {
    jpeg(paste0(rep,"/carte",i,".jpg"),pointsize = 12,res=130, width = fdim[1], height = fdim[2])
    
    choroLayer(spdf = carte_ze, df = base, spdfid = "code", dfid ="ze" ,var = nom[i],
               method="q6",col=cols,
               border = NA, legend.title.txt = paste0("nb entreprises \n creees- ",2008+i)
    )
    
    dev.off()
  }
  
  #gif
  
  #liste des images
  l_img<- data.frame(dir(rep,pattern="*.jpg"))
  
  for (i in 1:nrow(l_img)) {
    jpg.dat <- image_read(paste0(rep,"/",l_img[i,1]))
    if(i==1){
      images_list <- c(jpg.dat)
    }else {
      images_list <- c(images_list,jpg.dat)
    }
  }
  
  gif <- image_animate(images_list, fps = 1, dispose = "previous")
  image_write(gif,paste0(getwd(),"/ze.gif"))
  
  return(image_animate(images_list, fps = 1, dispose = "previous"))
}



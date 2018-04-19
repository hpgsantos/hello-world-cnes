library(curl)
library(dplyr)
library(jsonlite)


alljson <- fromJSON("data/tidy_cnes_loc_censo_pessoa_renda.json")

alljson <- alljson$docs[,c(1:38)]

alljson$lat <- as.numeric(alljson$lat)
alljson$long <- as.numeric(alljson$lon)
alljson$mag <- 1

drops <- c("")
alljson <- alljson[ , !(names(alljson) %in% drops)]

allcnes <- alljson %>% 
  group_by(CNES) %>% 
  summarize(qtd_cnes =  n(), mg=2, cod_mun = max(CODUFMUN), num_ano = max(as.numeric(X_ANO)) + 2000, sgl_uf=max(X_UF), qtd_exist = sum(as.numeric(QT_EXIST)), qtd_sus = sum(as.numeric(QT_SUS)), lat = max(lat), long = max(long) )

allcnes <- as.data.frame(allcnes)
#allcnes <- head(allcnes,50)


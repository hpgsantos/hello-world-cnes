library(curl)
library(dplyr)
library(jsonlite)

options(digits=12)

cnes.estabelecimentos <- read.table(file = "/home/henrique/var/www/unb/hello-world-cnes/dados/cnes_estabelecimentos.csv", sep = ",", quote = "\"", dec = ",",stringsAsFactors = FALSE ,header = TRUE);

allcnes  <- cnes.estabelecimentos  %>% 
  group_by(CNES) %>% 
  summarize(qtd_cnes =  n(), num_ano = max(as.numeric(X_ANO)) + 2000, sgl_uf=max(X_UF), qtd_leito = (sum(QTLEITP1) + sum(QTLEITP2) + sum(QTLEITP3)), lat = max(as.numeric(lat)), long = max(as.numeric(long)))

allcnes <- as.data.frame(allcnes)
allcnes <- head(allcnes,50)

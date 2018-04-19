
if(!require(httr))  install.packages("httr")
if(!require(dplyr))  install.packages("dplyr")
if(!require(ggplot2)) install.packages("ggplot2")


### Consumo de API por CSV

  ### Atribuicao direta

  ## censo.setores <- read.table(file = "http://<HOSTNAME>/api/censogeo/5300108?format=csv&cache=true&incluirRenda=true", sep = ",", quote = "\"", dec = ",", header = TRUE);
  ## cnes.estabelecimentos <- read.table(file = "http://<HOSTNAME>/api/estabelecimentos/5300108/all?format=csv&cache=true", sep = ",", quote = "\"", dec = ".", header = TRUE);

  ### Download do arquivo
  
    ## if(!require(RCurl)) library(RCurl)

    # download.file("http://<HOSTNAME>/api/estabelecimentos/5300108/all?format=csv&cache=true", destfile = file.path("dados", "cnes_estabelecimentos.csv"))
    # download.file("http://<HOSTNAME>/api/censogeo/5300108?format=csv&cache=true&incluirRenda=true", destfile = file.path("dados", "censo_setores.csv"))
    
    ## censo.setores <- read.table(file = file.path("dados", "censo_setores.csv") , sep = ",", quote = "\"", dec = ",", header = TRUE);
    ## cnes.estabelecimentos <- read.table(file = file.path("dados", "cnes_estabelecimentos.csv"), sep = ",", quote = "\"", dec = ".", header = TRUE);


censo.setores <- read.table(file = file.path("dados", "censo_setores.csv") , sep = ",", quote = "\"", dec = ",", header = TRUE);


cnes.estabelecimentos <- read.table(file = file.path("dados", "cnes_estabelecimentos.csv"), sep = ",", quote = "\"", dec = ".", header = TRUE);


str(cnes.estabelecimentos)
colnames(cnes.estabelecimentos)

cnes.estabelecimentos <- mutate(cnes.estabelecimentos, QTLEITO = (QTLEITP1 + QTLEITP2 + QTLEITP3))
cnes.estabelecimentos <- cnes.estabelecimentos[,c("long","lat","VINC_SUS","QTLEITO")]


cnes.estabelecimentos$VINC_SUS <- as.factor(cnes.estabelecimentos$VINC_SUS)

summary(censo.setores$basicoV002)

ggplot(data = censo.setores, aes(x = longitude, y = latitude, group = setor, fill = basicoV002)) + 
  geom_polygon()  +
  geom_path(color = "black") +
  scale_fill_gradient(low = "yellow", high = "green", breaks=c(3000,2500,2000,1500,1000,500),labels=c("3.000","2.500","2.000","1.500","1.000","500")) +
  coord_equal() +
  geom_point(data = cnes.estabelecimentos, aes(long, lat, colour = VINC_SUS, size = QTLEITO),show.legend = TRUE, inherit.aes = FALSE) +
  labs(title = "Distribuição de Estabelecimentos de Saúde Vinculados ao SUS", fill = "Número de Habitantes") 
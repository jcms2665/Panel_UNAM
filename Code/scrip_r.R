


#**********************************
#    Construccion de secuencias
#**********************************

# Julio Cesar Martinez Sanchez
# jcms2665@gmail.com


# Contenido

#1. Instalación de paquetes
#2. Cargar librerias
#3. Ruta
#4. Cargar bases
#5. Generar subbases para cada panel
#6. Tomar la base de referencia 
#7. Union de los paneles 
#8. Cambios sociodemograficos


#1. Instalación de paquetes

install.packages(c("foreign","TraMineR","cluster","stats","base","survey"))
install.packages(c("data.table","dplyr"))
install.packages(c("questionr"))
install.packages("devtools")
install.packages("data.table")
install.packages("sqldf")



#2. Cargar librerias

library(foreign)
library(TraMineR)
library(cluster)
library(stats)
library(base)
library(questionr)
library(data.table)
library(dplyr)
library(sqldf)

#3. Ruta

setwd("C:\\Users\\Julio Cesar\\Desktop\\BUAP-master\\Datos\\ENOE09")
rm(list = ls())


#4. Cargar bases

sdemt1 <- read.dbf("sdemt109.dbf")
sdemt2 <- read.dbf("sdemt209.dbf")
sdemt3 <- read.dbf("sdemt309.dbf")
sdemt4 <- read.dbf("sdemt409.dbf")
sdemt5 <- read.dbf("sdemt110.dbf")


#5. Generar subbases para cada panel

i=2
for(sdemt in paste("sdemt",2:5,sep="")){
  h<-get(sdemt)
  h$R_DEF<-as.numeric(as.character(h$R_DEF))
  h$C_RES<-as.numeric(as.character(h$C_RES))
  h$N_ENT<-as.numeric(as.character(h$N_ENT))
  h$CLASE1<-as.numeric(as.character(h$CLASE1))
  k<- paste(h$CD_A, h$ENT, h$CON, h$V_SEL, h$N_HOG, h$H_MUD, h$N_REN)
  gsub(" ", "", k)
  h<-data.frame (h, k)
  h<-subset(h, h$N_ENT==i & h$R_DEF==0 & (h$C_RES==1 | h$C_RES==3),select = c("k", "CLASE1", "N_ENT"))
  names(h)[2] <- c(paste("CLASE1_",i,sep=""))
  assign(paste("h_",i,sep=""),h,envir = .GlobalEnv)
  i=i+1
}


#6. Tomar la base de referencia 

k<- paste(sdemt1$CD_A, sdemt1$ENT, sdemt1$CON, sdemt1$V_SEL, 
          sdemt1$N_HOG, sdemt1$H_MUD, sdemt1$N_REN)
gsub(" ", "", k)
sdemt1<-data.frame (sdemt1, k)


#7. Union de los paneles 

BaseGral<-merge(sdemt1,h_2[,1:2], by = "k", all.x = TRUE)
head(BaseGral)
BaseGral<-merge(BaseGral,h_3[,1:2], by = "k", all.x = TRUE)
head(BaseGral)
BaseGral<-merge(BaseGral,h_4[,1:2], by = "k", all.x = TRUE)
head(BaseGral)
BaseGral<-merge(BaseGral,h_5[,1:2], by = "k", all.x = TRUE)
head(BaseGral)


#8. Cambios sociodemograficos

BaseGral$cambio<-0
BaseGral$cambio[as.numeric(BaseGral$CLASE1)== 1 & as.numeric(BaseGral$CLASE1_2)== 1 & as.numeric(BaseGral$CLASE1_3)== 1 &
                  as.numeric(BaseGral$CLASE1_4)== 1 & as.numeric(BaseGral$CLASE1_5)== 1] <- 1

wtd.table(BaseGral$cambio)

wtd.table(BaseGral$N_ENT)


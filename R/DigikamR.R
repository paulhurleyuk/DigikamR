# TODO: Add comment
# 
# Author: Paul Hurley
###############################################################################


library(RSQLite)
library(ggplot2)
library(plyr)

m<-dbDriver("SQLite")
basedir<-"/home/paul/RStudio/DigikamR/"
con<-dbConnect(m,dbname=paste(basedir, "data/digikam4.db",sep=""))

#List the tables in the database
dbListTables(con)

#List the columns of some of the interesting tables
names(dbReadTable(con, "ImageInformation"))
names(dbReadTable(con, "ImageComments"))
names(dbReadTable(con, "ImageMetadata"))
names(dbReadTable(con, "ImageProperties"))
names(dbReadTable(con, "ImagePositions"))
names(dbReadTable(con, "Images"))
names(dbReadTable(con, "TagProperties"))
names(dbReadTable(con, "Settings"))

#Pull some of the information together
Imgs<-dbReadTable(con, "Images")
ImgComments<-dbReadTable(con, "ImageComments")
ImgMeta<-dbReadTable(con, "ImageMetadata")
ImgInfo<-dbReadTable(con, "ImageInformation")

#and merge it together
ImgMerge<-merge(Imgs, ImgMeta, by.x="id", by.y="imageid")
ImgMerge<-merge(ImgMerge, ImgInfo, by.x="id", by.y="imageid")

#clean it up
ImgMerge$make<-as.factor(ImgMerge$make)
ImgMerge$model<-as.factor(ImgMerge$model)

ImgMerge$faperture<-as.factor(ImgMerge$aperture)
ImgMerge$fexposureTime<-as.factor(ImgMerge$exposureTime)
ImgMerge$fmodel<-as.factor(ImgMerge$model)

ImgMerge$Year<-format(as.POSIXct(ImgMerge$creationDate), format="%Y")
ImgMerge$Month<-format(as.POSIXct(ImgMerge$creationDate), format="%b")

#and draw some graphs
qplot(data=ImgMerge, x=focalLength, geom="histogram", colour=as.factor(model))+facet_grid(model~.)


qplot(data=ImgMerge, x=as.numeric(as.character(aperture)), 
      y=log(as.numeric(as.character(exposureTime))), 
      colour=as.factor(model), geom="point")

#and draw some graphs
ggplot(data=subset(ImgMerge, model=="NIKON D5000"), 
      aes(x=focalLength))+geom_histogram(binwidth=5)+
        facet_grid(Year~.)

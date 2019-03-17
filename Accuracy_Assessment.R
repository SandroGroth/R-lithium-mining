library(raster)
library(RStoolbox)
library(rgdal)
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/confusionMatrix.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/overallAccuracy.R")

# Prepare NDWI image
ndwi_img <- brick("/home/sandro/Desktop/NDWI/Reserve_Area/NDWI_Reserve_Area_2018_LC08.tif")
threshold <- 0
ndwi_img[ndwi_img <= threshold] <- 0
ndwi_img[ndwi_img > threshold] <- 1
plot(ndwi_img)

val_shp <- readOGR("/home/sandro/Validation_Samples.shp")
val_ras <- rasterize(val_shp, ndwi_img, field = "id")
val_ras[val_ras == 1] <- 0
val_ras[val_ras == 2] <- 1

ndwi_masked <- mask(ndwi_img, val_ras, maskvalue = NA, updatevalue = NA)

confusion_matrix <- confusionMatrix(val_ras, ndwi_masked)

acc <- overallAccuracy(confusion_matrix, in_percent = TRUE)

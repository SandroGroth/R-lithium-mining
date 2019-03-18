library(raster)
library(RStoolbox)
library(rgdal)
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/confusionMatrix.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/overallAccuracy.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/sensitivity.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/specificity.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/youdenIndex.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/binaryMap.R")

sensitivity_df <- data.frame(matrix(ncol = 2, nrow = 0))
names(sensitivity_df) <- c("Threshold", "Accuracy")

thresholds <- seq(-0.20, 0.50, by = 0.01)

# Prepare data
ndwi_img <- brick("/home/sandro/Desktop/NDWI/Reserve_Area/raw/NDWI_Reserve_Area_1989_LT05.tif")
val_shp <- readOGR("/home/sandro/Validation_L5.shp")
val_ras <- rasterize(val_shp, ndwi_bin, field = "id")
val_ras[val_ras == 1] <- 0
val_ras[val_ras == 2] <- 1

# test all thresholds
for (i in 1:length(thresholds)) {
  ndwi_bin <- binaryMap(ndwi_img, thresholds[i])
  ndwi_masked <- mask(ndwi_bin, val_ras, maskvalue = NA, updatevalue = NA)
  confusion_matrix <- confusionMatrix(val_ras, ndwi_masked)
  acc <- overallAccuracy(confusion_matrix, in_percent = TRUE)
  sensitivity_df[i,1] <- thresholds[i]
  sensitivity_df[i,2] <- acc
  message(paste0("Threshold: ", as.character(thresholds[i]), " Accuracy: ", as.character(acc)))
}

plot(sensitivity_df$Threshold, sensitivity_df$Accuracy)
 
library(raster)
library(RStoolbox)
library(rgdal)

# Prepare NDWI image
ndwi_img <- brick("/home/sandro/Desktop/NDWI/Reserve_Area/NDWI_Reserve_Area_2018_LC08.tif")
ndwi_img[ndwi_img <= 0.1] <- 0
ndwi_img[ndwi_img > 0.1] <- 1


val_shp <- readOGR("/home/sandro/Validation_Samples.shp")
val_ras <- rasterize(val_shp, ndwi_img, field = "id")
val_ras[val_ras == 1] <- 0
val_ras[val_ras == 2] <- 1

ndwi_masked <- mask(ndwi_img, val_ras, maskvalue = NA, updatevalue = NA)

acc_stack <- stack(val_ras, ndwi_masked)
true_positive <- 0
false_negative <- 0
true_negative <- 0
false_positive <- 0
NAs <- 0

# Loopiloop
for (i in 1:nrow(acc_stack[[1]])) {
  for (j in 1:ncol(acc_stack[[1]])) {
    if (is.na(acc_stack[[1]][i,j])) {
      #NAs <- NAs + 1
      #message(paste0("NAs: ", as.character(NAs)))
    }
    else if (acc_stack[[1]][i,j] == 1) {
      if (acc_stack[[2]][i,j] == 1) {
        true_positive <- true_positive + 1
        message(paste0("Added True Positive to: ", as.character(true_positive)))
      } else {
        false_negative <- false_negative + 1
        message(paste0("Added False Negative to: ", as.character(false_negative)))
      }
    } else {
      if (acc_stack[[2]][i,j] == 0) {
        true_negative <- true_negative + 1
        message(paste0("Added True Negative to: ", as.character(true_negative)))
      } else {
        false_positive <- false_positive + 1
        message(paste0("Added False Positive to: ", as.character(false_positive)))
      }
    }
  }
}

overall_acc <- (true_positive + true_negative) / (true_positive + true_negative + false_negative + false_positive)
overall_acc

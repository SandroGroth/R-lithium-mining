library(raster)
library(rasterVis)
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/getYear.R")

open_water_files <- list.files("/home/sandro/Desktop/NDWI/Reserve_Area/threshold_0_05", pattern = ".tif", full.names = T, no.. = T)
moisture_files <- list.files("/home/sandro/Desktop/NDMI/Reserve_Area/threshold_0", pattern = ".tif", full.names = T, no.. = T)
out_folder <- "/home/sandro/Desktop/Classification/Reserve_Area"


for (i in 1:length(open_water_files)) {
  open_water <- brick(open_water_files[i])
  year <- getYear(open_water_files[i])
  moisture <- brick(moisture_files[i])
  class_ras <- open_water # create a sample raster that gets filled with values
  class_ras[] <- 0
  class_ras[moisture == 1] <- 1
  class_ras[open_water == 1] <- 2
  writeRaster(class_ras, filename = paste0(out_folder, "/Index_Classification_", year, ".tif"), format = "GTiff", overwrite = T)
  message(paste0("Classified file: ", open_water_files[i]))
}

classified_files <- list.files(out_folder, pattern = ".tif", full.names = T, no.. = T)

stacked <- stack()
for (i in 1:length(classified_files)) {stacked <- stack(stacked, brick(classified_files[i]))}

levelplot(stacked, par.settings = RdBuTheme)

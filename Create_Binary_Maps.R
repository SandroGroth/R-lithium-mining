library(raster)
library(RStoolbox)
library(rgdal)
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/binaryMap.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/getYear.R")


# Calculate binary map and safe it to new folder
ndwi_files <- list.files(path = "/home/sandro/Desktop/NDWI/Reserve_Area/raw", pattern = ".tif", full.names = TRUE, no.. = TRUE)
out_folder <- "/home/sandro/Desktop/NDWI/Reserve_Area/threshold_0_05"
threshold <- 0.05
for (i in 1:length(ndwi_files)) {
  ndwi_ras <- brick(ndwi_files[i])
  year <- getYear(ndwi_files[i])
  bin_map <- binaryMap(ndwi_ras, threshold)
  writeRaster(bin_map, filename = paste0(out_folder, "/Binary_Map_Water_", year, ".tif"), format = "GTiff", overwrite = T)
  message(paste0("Processed file: ", ndwi_files[i]))
}

# Calculate binary map for NDMI and safe it to new folder
ndmi_files <- list.files(path = "/home/sandro/Desktop/NDMI/Reserve_Area/raw", pattern = ".tif", full.names = TRUE, no.. = TRUE)
out_folder <- "/home/sandro/Desktop/NDMI/Reserve_Area/threshold_0"
for (i in 1:length(ndmi_files)) {
  threshold <- 0
  ndmi_ras <- brick(ndmi_files[i])
  sensor <- NA
  if (grepl("LC08", ndmi_files[i])) {threshold <- 0.19}
  year <- getYear(ndmi_files[i])
  bin_map <- binaryMap(ndmi_ras, threshold)
  writeRaster(bin_map, filename = paste0(out_folder, "/Binary_Map_Moisture_", year, ".tif"), format = "GTiff", overwrite = T)
  message(paste0("Processed file: ", ndmi_files[i], " Threshold: ", as.character(threshold)))
}

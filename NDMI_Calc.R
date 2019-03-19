library(RStoolbox)
library(raster)
library(rgdal)
library(leaflet)
library(ggplot2)
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/mndwi.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/clip.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/ndwi.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/getYear.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/ndmi.R")

setwd("/home/sandro/Desktop/LS_Atacama")
out_path <- "/home/sandro/Desktop/NDMI"

study_area_shp <- readOGR("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/vector/Study_Area.shp")
mining_area_shp <- readOGR("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/vector/Mining_Area.shp")
reserve_area_shp <- readOGR("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/vector/Nature_Reserve_Area.shp")

study_area <- subset(study_area_shp, id==1)
mining_area <- subset(mining_area_shp, id==1)
reserve_area <- subset(reserve_area_shp, id==1)

dirs <- list.dirs(full.names = TRUE)
dirs <- dirs[-1]

ndmis <- lapply(dirs, ndmi)

#-----------------------------------------------------------------------------------------------------------------
# Export NDmI Study area
ndmis_study_area <- lapply(ndmis, clip, feature = study_area)
i <- 1
for (i in 1:length(ndmis_study_area)) {
  sensor <- substring(dirs[i], 3, 6)
  year <- getYear(dirs[i])
  writeRaster(ndmis_study_area[[i]], paste0(out_path, "/Study_Area/raw/NDMI_Study_Area", "_", year, "_", sensor, ".tif"),
              format = "GTiff", overwrite = TRUE)
  print(paste0("Year processed: ", year))
}

# Export NDMI for Mining Area
ndmis_mining_area <- lapply(ndmis, clip, feature = mining_area)
i <- 1
for (i in 1:length(ndmis_mining_area)) {
  sensor <- substring(dirs[i], 3, 6)
  year <- getYear(dirs[i])
  writeRaster(ndmis_mining_area[[i]], paste0(out_path, "/Mining_Area/raw/NDMI_Mining_Area", "_", year, "_", sensor, ".tif"),
              format = "GTiff", overwrite = TRUE)
  print(paste0("Year processed: ", year))
}

# Export NDMI for Nature Reserve Area
ndmis_reserve_area <- lapply(ndmis, clip, feature = reserve_area)
i <- 1
for (i in 1:length(ndmis_reserve_area)) {
  sensor <- substring(dirs[i], 3, 6)
  year <- getYear(dirs[i])
  writeRaster(ndmis_reserve_area[[i]], paste0(out_path, "/Reserve_Area/raw/NDMI_Reserve_Area", "_", year, "_", sensor, ".tif"),
              format = "GTiff", overwrite = TRUE)
  print(paste0("Year processed: ", year))
}

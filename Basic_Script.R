library(RStoolbox)
library(raster)
library(rgdal)
library(leaflet)
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/mndwi.R")

setwd("/home/sandro/Desktop/LS_Atacama")
out_path <- "/home/sandro/Desktop/MNDWI/Study_Area"

study_area_shp <- readOGR("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/vector/Study_Area.shp")
mining_area_shp <- readOGR("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/vector/Mining_Areas.shp")
reserve_area_shp <- readOGR("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/vector/Nature_Reserve.shp")

study_area <- subset(study_area_shp, id==1)

dirs <- list.dirs(full.names = TRUE)
dirs <- dirs[-1] # remove first element "."

mndwis <- lapply(dirs, mndwi)
mndwis_study_area <- lapply(mndwis, mask, mask = study_area)

# Export
i <- 1
for (i in 1:length(mndwis_study_area)) {
  sensor <- substring(dirs[i], 3, 6)
  year <- substring(dirs[i], 20, 27)
  writeRaster(mndwis_study_area[[i]], paste0(out_path, "/MNDWI_Study_Area", "_", year, "_", sensor, ".tif"),
              format = "GTiff", overwrite = TRUE)
  print(paste0("Year processed: ", year))
}
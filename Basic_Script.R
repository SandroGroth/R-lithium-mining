library(RStoolbox)
library(raster)
library(rgdal)
library(leaflet)

setwd("/home/sandro/Desktop/LS_Atacama")
out_path <- "/home/sandro/Desktop/MNDWI"

study_area_shp <- readOGR("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/vector/Study_Area.shp")
mining_area_shp <- readOGR("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/vector/Mining_Areas.shp")
reserve_area_shp <- readOGR("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/vector/Nature_Reserve.shp")

study_area <- subset(study_area_shp, id==1)

dirs <- list.dirs()
i <- 0
while (i < length(dirs)) {
  if (i > 1) {
    act_dir <- dirs[i]
    all_bands <- list.files(act_dir, pattern = ".TIF", full.names = T)
    l_GREEN <- brick(all_bands[5])
    l_SWIR2 <- brick(all_bands[9])
    ndwi_stack <- stack(l_GREEN, l_SWIR2)
    mndwi <- spectralIndices(ndwi_stack, green = 1, swir2 = 2, indices = "MNDWI")
    mndwi_masked <- mask(mndwi, study_area)
    plot(mndwi_masked)
    writeRaster(mndwi_masked, paste0(out_path, "/MNDVI", as.character(i), ".tif"), format = "GTiff", overwrite = T)
  }
  i <- i + 1
}
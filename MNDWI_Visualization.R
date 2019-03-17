library(rasterVis)
library(ggplot2)
library(raster)

setwd("/home/sandro/Desktop/MNDWI")

files = list.files(path = "./Study_Area", pattern = ".tif", full.names = TRUE)

mndwi_stack <- stack()
i <- 1
for (i in 1:length(files)) {
  band <- brick(files[i])
  mndwi_stack <- stack(mndwi_stack, band)
  year <- substring(files[i], 20, 23)
  names(mndwi_stack[[i]]) <- year
  print(paste0("Year stacked: ", year))
}

cuts <- c(0.11, 0.25, 1)
BuRamp <- colorRampPalette(brewer.pal(9, "YlGn"))
BuTheme <- rasterTheme(region = brewer.pal('Blues', n=3))
levelplot(mndwi_stack, par.settings = BuTheme, at = cuts)

#-----------------------------------------
files = list.files(path = "./Mining_Area", pattern = ".tif", full.names = TRUE)

mndwi_stack <- stack()
i <- 1
for (i in 1:length(files)) {
  band <- brick(files[i])
  mndwi_stack <- stack(mndwi_stack, band)
  year <- substring(files[i], 33, 36)
  names(mndwi_stack[[i]]) <- year
  print(paste0("Year stacked: ", year))
}

levelplot(mndwi_stack, par.settings = BuTheme, at = cuts)

#----------------------------------------
files = list.files(path = "./Reserve_Area", pattern = ".tif", full.names = TRUE)

reserve_mndwi_stack <- stack()
i <- 1
for (i in 1:length(files)) {
  band <- brick(files[i])
  reserve_mndwi_stack <- stack(reserve_mndwi_stack, band)
  year <- substring(files[i], 35, 38)
  names(reserve_mndwi_stack[[i]]) <- year
  print(paste0("Year stacked: ", year))
}

levelplot(reserve_mndwi_stack, par.nsettings = BuTheme, at = cuts)

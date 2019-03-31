# Import packages
library(raster)
library(RStoolbox)
library(rgdal)
library(rgeos)
library(plyr)
library(ggplot2)
library(rasterVis)

# Import own functions
source("./binaryMap.R")
source("./clip.R")
source("./confusionMatrix.R")
source("./getArea.R")
source("./getYear.R")
source("./ndmi.R")
source("./ndwi.R")

################################ 1.) Calculate NDWI and export it ##################################

setwd("/home/sandro/Desktop/LS_Atacama")

# load shapefile with extent of Soncor Ecosystem
study_area_shp <- readOGR("./vector/Reserve_Area.shp")
reserve_area <- subset(reserve_area_shp, id==1)

# list all unpacked Landsat image folders
dirs <- list.dirs(full.names = TRUE)
dirs <- dirs[-1]    # remove firt element "."     

# calculate the NDWI for every image in dirs
ndwis <- lapply(dirs, ndwi)

# clip the result to the study area
ndwis_reserve_area <- lapply(ndwis, clip, feature = reserve_area)

# export all clipped NDWI rasters into the out_folder
out_path <- "/home/sandro/Desktop/NDWI"
for (i in 1:length(ndwis_reserve_area)) {
  sensor <- substring(dirs[i], 3, 6)
  year <- getYear(dirs[i])
  writeRaster(ndwis_reserve_area[[i]], paste0(out_path, "/Study_Area/raw/NDWI_Reserve_Area", "_", year, "_", sensor, ".tif"),
              format = "GTiff", overwrite = TRUE)
  print(paste0("Year processed: ", year))
}

################################ 2.) Calculate NDMI and export it ##################################

# calculate the NDWI for every image in dirs
ndmis <- lapply(dirs, ndmi)

# clip the result to the study area
ndmis_reserve_area <- lapply(ndmis, clip, feature = reserve_area)

# export all clipped NDWI rasters into the out_folder
out_path <- "/home/sandro/Desktop/NDMI"
for (i in 1:length(ndmis_reserve_area)) {
  sensor <- substring(dirs[i], 3, 6) # extract sensor from folder name
  year <- getYear(dirs[i])  # extract year from folder name
  writeRaster(ndmis_reserve_area[[i]], paste0(out_path, "/Study_Area/raw/NDMI_Reserve_Area", "_", year, "_", sensor, ".tif"),
              format = "GTiff", overwrite = TRUE)
  print(paste0("Year processed: ", year))
}

########################## 3.)  Create Binary Maps using thresholds ################################

# Calculate binary map and safe it to new folder
ndwi_files <- list.files(path = "/home/sandro/Desktop/NDWI/Reserve_Area/raw", pattern = ".tif", full.names = TRUE, no.. = TRUE)
out_folder <- "/home/sandro/Desktop/NDWI/Reserve_Area/threshold_0_05"
threshold <- 0.05   # set threshold
for (i in 1:length(ndwi_files)) {
  ndwi_ras <- brick(ndwi_files[i])    # load raster
  year <- getYear(ndwi_files[i])      # extract year from file name
  bin_map <- binaryMap(ndwi_ras, threshold)   # calculate binary map using the set threshold
  writeRaster(bin_map, filename = paste0(out_folder, "/Binary_Map_Water_", year, ".tif"), format = "GTiff", overwrite = T)
  message(paste0("Processed file: ", ndwi_files[i]))
}

# Calculate binary map for NDMI and safe it to new folder
ndmi_files <- list.files(path = "/home/sandro/Desktop/NDMI/Reserve_Area/raw", pattern = ".tif", full.names = TRUE, no.. = TRUE)
out_folder <- "/home/sandro/Desktop/NDMI/Reserve_Area/threshold_0"
for (i in 1:length(ndmi_files)) {
  threshold <- 0  # set thrashold for Landsat 5
  ndmi_ras <- brick(ndmi_files[i])  # load raster
  if (grepl("LC08", ndmi_files[i])) {
    threshold <- 0.19   # overwrite threshold when sensor type is Landsat 8
  }
  year <- getYear(ndmi_files[i])  # extract year from file name
  bin_map <- binaryMap(ndmi_ras, threshold)   # calculate binary map using the set threshold
  writeRaster(bin_map, filename = paste0(out_folder, "/Binary_Map_Moisture_", year, ".tif"), format = "GTiff", overwrite = T)
  message(paste0("Processed file: ", ndmi_files[i], " Threshold: ", as.character(threshold)))
}


########################## 4.) Execute rule based classification ###################################

open_water_files <- list.files("/home/sandro/Desktop/NDWI/Reserve_Area/threshold_0_05", pattern = ".tif", full.names = T, no.. = T)
moisture_files <- list.files("/home/sandro/Desktop/NDMI/Reserve_Area/threshold_0", pattern = ".tif", full.names = T, no.. = T)
out_folder <- "/home/sandro/Desktop/Classification/Reserve_Area"

# Iterate through NDWI layers to get the interval of i
for (i in 1:length(open_water_files)) {
  open_water <- brick(open_water_files[i])  # Load NDWI binary map
  year <- getYear(open_water_files[i])      # Extract year from filename
  moisture <- brick(moisture_files[i])      # Load NDMI binary map
  class_ras <- open_water                   # create a sample raster that gets filled with values
  class_ras[] <- 0                          # fill sample raster with 0s, represents dry area
  class_ras[moisture == 1] <- 1             # set all pixels to 1 that have a NDMI Binary Map value of 1
  class_ras[open_water == 1] <- 2           # set all pixels to 2 that have a NDWI Binary Map value of 1
  writeRaster(class_ras, filename = paste0(out_folder, "/Index_Classification_", year, ".tif"), format = "GTiff", overwrite = T)
  message(paste0("Classified file: ", open_water_files[i]))
}

################################## 5.) Get the mining pond area ####################################

mining_ponds_shp <- readOGR("/home/sandro/Mining_Ponds.shp", "Mining_Ponds")  # Read mining pond shapefile

features <- mining_ponds_shp@data   # extraxt features as data frame

# Create a new empy dataframe and fill in the years
area_df <- data.frame(matrix(ncol = 3, nrow = 30))
names(area_df) <- c("year", "a_ponds", "a_cumulative")
area_df$year <- seq(from = 1989, to = 2018, by = 1)
area_df$a_ponds <- 0

# fill data frame with values
for (i in 1989:2018) {
  area_df[i-1988,2] <- sum(features[features$year == i,4])  # calculate the area of new ponds for every year
  area_df[i-1988,2] <- area_df[i-1988,2] * 1e-6             # convert into km^2
  message(area_df[i-1988,])
}

area_df[,3] <- cumsum(area_df[ ,2])   # add the cumulative area
area_total <- sum(area_df[,2])        # calculate the total mining pond are

# Create a visualization
ggplot(data = area_df) +
  geom_area(aes(x = area_df$year, y= area_df$a_cumulative, color = "Evaporation Ponds"))+
  labs(x = "Year", y = "Area in km²", colour = "Legend", title = "Area of mining evaporation ponds in the Salar de Atacama (1989 - 2018)")+
  theme_classic(base_size = 15)+
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 45, margin = margin(10,0,0,0)))

################################ 6.) Get the classified Lagoon areas #################################

# Create a new empty data frame with named columns
area_df <- data.frame(matrix(ncol = 4, nrow = 0))
names(area_df) <- c("year", "a_dry", "a_wet", "a_open_water")

# Calculate the areas from the classified rasters
for (i in 1:length(files)) {
  area_df[i,1] <- getYear(files[i])
  class_ras <- brick(files[i])
  area_df[i,2] <- getArea(class_ras, 0)  # add dry
  area_df[i,3] <- getArea(class_ras, 1)  # add moisture
  area_df[i,4] <- getArea(class_ras, 2)  # add open water
  #area_df[i,3] <- area_df[i,3] - area_df[i,4] # substract open water from moisture
  message(area_df[i,])
}

# Plot Moist area with regression line
moist_area_plot <- ggplot(data = area_df, aes(x = year, y = a_wet, group = 1)) + 
  geom_line(data = area_df, aes(x = year, y = a_wet), color = "#00B0FF") +
  geom_smooth(method = "lm", se = F, color = "#5D65AB", size = 0.3) +
  labs(x = "Year", y = "Area in km²") +
  theme_classic(base_size = 15) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, margin = margin(10,0,0,0)))
moist_area_plot

# plot open water area with regression line
water_area_plot <- ggplot(data = area_df, aes(x = year, y = a_open_water, group = 1)) + 
  geom_line(data = area_df, aes(x = year, y = a_open_water), color = "#000AE2") +
  geom_smooth(method = "lm", se = F, color = "#5D65AB", size = 0.3) +
  labs(x = "Year", y = "Area in km²") +
  theme_classic(base_size = 15) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, margin = margin(10,0,0,0)))
water_area_plot

# Combine both graphs
moist_area_plot + water_area_plot

# Create map levelplot for all years
classifiles <- list.files("/home/sandro/Desktop/Classification/Reserve_Area", pattern = ".tif", full.names = T, no.. = T)

classifstack <- stack(classifiles)
raster_names <- gsub("Index_Classification_", "", names(classifstack))

BuTheme <- rasterTheme(region = brewer.pal('Blues', n=3))
cuts <- c(0.1, 1.1, 2.1)

levelplot(classifstack,
          par.settings = BuTheme, 
          names.attr = raster_names, 
          scales = list(draw=F), 
          colorkey = F,
          at = cuts)

####################################### 7.) Compute Correlation ###################################

# combine the data frames to compute correlations
mining_area <- area_df[area_df$year >1991,]
merged <- merge(x = mining_area, y = reserve_area_df, by = "year", all = TRUE)
merged <- merged[, !(names(merged) %in% c("a_ponds", "year"))]

correlation <- cor(merged, use = "complete.obs")

################################### 8.) Accuracy Assessment of NDWI ###############################

val_polygon_shp <- readOGR("/home/sandro/Validation_Samples.shp")
classif_raster <- brick("/home/sandro/Desktop/NDWI/Reserve_Area/threshold_0_05/Binary_Map_Water_2018.tif")

unique_classes <- unique(val_polygon_shp$class_name)

# Extracting classified values from raster and append to shapefile
set.seed(47)
xy_val <- lapply(unique_classes, function(class) {
  class_data <- subset(val_polygon_shp, class_name == class)
  classpts <- spsample(class_data, type = "random", n = 100)
  classpts$class <- rep(class, length(classpts))
  return(classpts)
})

# rbind the two Dataframes into one object
xy_val <- do.call("rbind", xy_val)

# extract predictions
pred <- extract(classif_raster$Binary_Map_Water_2018, xy_val, cellnumbers = TRUE)

# get rid of duplicate cells and the 'cells' column
dup <- duplicated(pred)
pred <- pred[!dup, "Binary_Map_Water_2018"]
obs <- xy_val$class[!dup]

# Convert integers to factors
valFactor <- factor(pred, levels = c(0,1), labels = c("no_water", "water"))

confusionMatrix(obs, reference = valFactor)

######################################### END OF ANALYSIS #########################################
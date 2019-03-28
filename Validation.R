library(raster)
library(rgdal)
library(caret)

val_polygon_shp <- readOGR("/home/sandro/Validation_Samples.shp")
classif_raster <- brick("/home/sandro/Desktop/NDWI/Reserve_Area/threshold_0_05/Binary_Map_Water_2018.tif")

unique_classes <- unique(val_polygon_shp$class_name)

# Extracting classified values from raster and append to shapefile
set.seed(25)
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

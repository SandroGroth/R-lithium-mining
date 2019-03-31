library(rgdal)
library(ggplot2)
library(rgeos)
library(plyr)

mining_ponds_shp <- readOGR("/home/sandro/Mining_Ponds.shp", "Mining_Ponds")

features <- mining_ponds_shp@data
head(features)

area_df <- data.frame(matrix(ncol = 3, nrow = 30))
names(area_df) <- c("year", "a_ponds", "a_cumulative")
area_df$year <- seq(from = 1989, to = 2018, by = 1)
area_df$a_ponds <- 0

for (i in 1989:2018) {
  area_df[i-1988,2] <- sum(features[features$year == i,4])
  area_df[i-1988,2] <- area_df[i-1988,2] * 1e-6
  message(area_df[i-1988,])
}

area_df[,3] <- cumsum(area_df[ ,2])
area_total <- sum(area_df[,2])

ggplot(data = area_df) +
  geom_area(aes(x = area_df$year, y= area_df$a_cumulative, color = "Evaporation Ponds"))+
  labs(x = "Year", y = "Area in km²", colour = "Legend", title = "Area of mining evaporation ponds in the Salar de Atacama (1989 - 2018)")+
  theme_classic(base_size = 15)+
  theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 45, margin = margin(10,0,0,0)))

#########################################################################################################
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/getArea.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/getYear.R")

files <- list.files("/home/sandro/Desktop/Classification/Reserve_Area", pattern = ".tif", full.names = T, no.. = T)
reserve_area_df <- data.frame(matrix(ncol = 4, nrow = 0))
names(reserve_area_df) <- c("year", "a_dry", "a_wet", "a_open_water")

for (i in 1:length(files)) {
  reserve_area_df[i,1] <- as.numeric(getYear(files[i]))
  class_ras <- brick(files[i])
  reserve_area_df[i,2] <- getArea(class_ras, 0)  # add dry
  reserve_area_df[i,3] <- getArea(class_ras, 1)  # add moisture
  reserve_area_df[i,4] <- getArea(class_ras, 2)  # add open water
  #area_df[i,3] <- area_df[i,3] - area_df[i,4] # substract open water from moisture
  message(reserve_area_df[i,])
}

ggplot(data = area_df)+
  geom_line(aes(x = area_df$year, y = area_df$a_cumulative)) +
  geom_line(data = reserve_area_df, aes(x = reserve_area_df$year), y = reserve_area_df$a_open_water) + 
  geom_line(data = reserve_area_df, aes(x = reserve_area_df$year), y = reserve_area_df$a_wet)
#######################################################################################################
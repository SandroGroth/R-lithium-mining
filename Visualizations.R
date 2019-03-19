library(raster)
library(ggplot2)
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/getArea.R")
source("/home/sandro/Documents/EAGLE_Data/WS201819_1st_Term/04GEOMB1_Digital_Image_Analysis/FInal_Project/R/R-lithium-mining/func/getYear.R")

files <- list.files("/home/sandro/Desktop/Classification/Reserve_Area", pattern = ".tif", full.names = T, no.. = T)
area_df <- data.frame(matrix(ncol = 4, nrow = 0))
names(area_df) <- c("year", "a_dry", "a_wet", "a_open_water")

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
ggplot(data = area_df, aes(x = year, y = a_wet, group = 1)) + 
  geom_line(data = area_df, aes(x = year, y = a_wet), color = "#00B0FF") +
  geom_smooth(method = "lm", se = F, color = "#5D65AB", size = 0.3) +
  labs(x = "Year", y = "Area in km²", title = "Moist surface area in the Soncor Ecosystem, Salar de 
       Atacama (1989-2018)", 
       caption = "(Data: NDMI calculated on Landsat 4, 5 and 8 imagery)") +
  theme_classic(base_size = 15) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, margin = margin(10,0,0,0)))

# plot open water area with regression line
ggplot(data = area_df, aes(x = year, y = a_open_water, group = 1)) + 
  geom_line(data = area_df, aes(x = year, y = a_open_water), color = "#000AE2") +
  geom_smooth(method = "lm", se = F, color = "#5D65AB", size = 0.3) +
  labs(x = "Year", y = "Area in km²", title = "Open water area in the Soncor Ecosystem, Salar de 
       Atacama (1989-2018)", 
       caption = "(Data: NDWI calculated on Landsat 4, 5 and 8 imagery)") +
  theme_classic(base_size = 15) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, margin = margin(10,0,0,0)))

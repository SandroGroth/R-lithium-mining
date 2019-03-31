library(raster)
library(ggplot2)
library(patchwork)
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

# Combine the two lines in one graph
combined_graph <- ggplot(data = area_df, aes(x = year, y = a_wet, group = 1)) + 
  geom_line(data = area_df, aes(x = year, y = a_wet), color = "#00B0FF") +
  geom_smooth(method = "lm", se = F, color = "#5D65AB", size = 0.3) +
  labs(x = "Year", y = "Moist Surface Area (km²)") +
  theme_classic(base_size = 15) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, margin = margin(10,0,0,0))) +
  geom_line(data = area_df, aes(x = year, y = a_open_water*20, group = 1), color = "#0000FF") +
  scale_y_continuous(sec.axis = sec_axis(~./20, name = "Open Water Area (km²)"))
combined_graph

moist_area_plot + water_area_plot

#--------------------AREA51------------------------------------
ggplot(data = area_df, aes(x = year, group = 1))+
  geom_line(aes(y = a_dry, color = "a_dry"))+
  geom_line(aes(y = a_wet, color = "a_wet"))+
  geom_line(aes(y = a_open_water))+
  scale_color_manual("",
                     breaks = c("a_dry, a_wet","a_open_water"),
                     values = c("red", "blue", "green"))+
  xlab("Year")+
  scale_y_continuous("Area", limits = c(0,1000))

library(reshape2)
df_reshape <- area_df[,c(1,2,3,4)]
df_reshape <- melt(df_reshape, id.vars =c("year"))

ggplot(df_reshape)+
  geom_line(aes(x = year, y = value, color = variable))+
  scale_color_manual(values = c("brown", "lightblue", "darkblue"))
dcast
#----------------------------------------------------------------

library(rasterVis)
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

mining_area <- area_df[area_df$year >1991,]
reserve_area_df

merged <- merge(x = mining_area, y = reserve_area_df, by = "year", all = TRUE)
merged

merged <- merged[, !(names(merged) %in% c("a_ponds", "year"))]
merged

correlation <- cor(merged, use = "complete.obs")
correlation

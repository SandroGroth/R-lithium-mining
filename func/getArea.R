getArea<- function(raster, class_value) {
  ras_res <- res(raster)
  values <- getValues(raster)
  area <- sum(values == class_value) * ras_res[1] *ras_res[2] * 1e-6
  return(area)
}
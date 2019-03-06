getArea<- function(raster, interval) {
  ras_res <- res(raster)
  values <- getValues(raster)
  area <- sum(values > interval[1] & values <= interval[2], na.rm =T) * ras_res[1] *ras_res[2] * 1e-6
  return(area)
}
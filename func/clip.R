clip <- function(raster, feature) {
  return(mask(crop(raster, feature), feature))
}
binaryMap <- function(raster, threshold) {
  
  bin <- raster
  bin[raster <= threshold] <- 0
  bin[raster > threshold] <- 1
  
  return(bin)
}
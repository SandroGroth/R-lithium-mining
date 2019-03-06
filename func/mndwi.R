mndwi <- function(band_folder, sensor_type="") {
  
  if (length(list.files(band_folder, pattern = "LT05|LT04")) != 0 | sensor_type == "l5") {
    b_green <- brick(list.files(band_folder, pattern = "B2.TIF", full.names = TRUE))
    b_swir <- brick(list.files(band_folder, pattern = "B5.TIF", full.names = TRUE))
    message("Sensor mode: LT05/LT04")
  } else if (length(list.files(band_folder, pattern = "LC08")) != 0 | sensor_type =="l8") {
    b_green <- brick(list.files(band_folder, pattern = "B3.TIF", full.names = TRUE))
    b_swir <- brick(list.files(band_folder, pattern = "B6.TIF", full.names = TRUE))
    message("Sensor mode: LC08")
  } else {
    stop("Unable to locate bands. Filenames must contain 'LC08', 'LT04' or 'LT05'")
  }
  
  #b_swir <- brick(list.files(band_folder, pattern = "B7.TIF", full.names = TRUE))
  stacked <- stack(b_green, b_swir)
  mndwi_res <- spectralIndices(stacked, green = 1, swir2 = 2, indices = "MNDWI")
  
  return(mndwi_res)
}
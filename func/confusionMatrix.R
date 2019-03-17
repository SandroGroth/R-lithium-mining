confusionMatrix <- function(ref_raster, obs_raster) {
  
  # TODO: Check on length and same extent usw.
  # Convert rasters into vector for better efficency
  ref_vec<- as.vector(ref_raster[[1]])
  obs_vec <- as.vector(obs_raster[[1]])
  
  # initialize confusion matrix with 0s
  conf_matrix <- matrix(0, nrow = 2, ncol = 2, dimnames = list(c("Obs. TRUE", "Obs. FALSE"), c("Ref. TRUE", "Ref. FALSE")))
  
  # loop through vectors and fill up confusion matrix
  for (i in 1:length(ref_vec)) {
    if (is.na(ref_vec[i])) {} # do nothing
    else if (ref_vec[i] == 1) {
      if (obs_vec[i] == 1) {conf_matrix[1,1] <- conf_matrix[1,1] + 1} # add to true positive
      else {conf_matrix[2,1] <- conf_matrix[2,1] + 1}} # add to false negative
    else {
      if (obs_vec[i] == 0) {conf_matrix[2,2] <- conf_matrix[2,2] + 1} # add to true negative
      else {conf_matrix[1,2] <- conf_matrix[1,2] + 1} # add to false positive
    }
  }
  
  return(conf_matrix)
}
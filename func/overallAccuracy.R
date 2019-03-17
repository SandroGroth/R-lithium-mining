overallAccuracy <- function(conf_matrix, in_percent=FALSE) {
  
  if (in_percent) {
    overall_acc <- (conf_matrix[1,1] + conf_matrix[2,2]) / sum(conf_matrix) * 100
  } else {
    overall_acc <- (conf_matrix[1,1] + conf_matrix[2,2]) / sum(conf_matrix)
  }
  
  
  return(overall_acc)
}
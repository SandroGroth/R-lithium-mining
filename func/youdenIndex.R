youdenIndex <- function(conf_matrix) {
  sensitivity <- conf_matrix[1,1] / conf_matrix[1,2]
  specificity <- conf_matrix[2,2] / (conf_matrix[2,2] + conf_matrix[1,2])
  youden <- sensitivity + specificity -1
  return(youden)
}
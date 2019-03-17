specificity <- function(conf_matrix) {
  spec <- conf_matrix[2,2] / (conf_matrix[2,2] + conf_matrix[1,2])
  return(spec)
}
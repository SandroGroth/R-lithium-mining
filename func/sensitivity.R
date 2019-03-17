sensitivity <- function(conf_matrix) {
  sens <- conf_matrix[1,1] / conf_matrix[1,2]
  return(sens)
}

# Based on Wikipedia (add Reference)
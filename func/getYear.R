getYear <- function(file) {
  for (i in 1:length(years)){
    if (grepl(years[i], file)) {
      return(years[i])
    }
  }
}
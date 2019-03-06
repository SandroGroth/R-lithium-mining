getYear <- function(file) {
  years <- as.character(c(1950:2020))
  for (i in 1:length(years)){
    if (grepl(years[i], file)) {
      return(years[i])
    }
  }
}
is_docker <- function() {
  if (file.exists("/.dockerenv")) {
    num <- as.numeric((gsub("\\.", "", system("curl -s ifconfig.me", intern = TRUE))))
    output <- paste0(num, ".XX", collapse = "")
    return(print(output))
  }else{
    num <- as.numeric((gsub("\\.", "", system("curl -s ifconfig.me", intern = TRUE))))
    output <- paste0(num, ".YY", collapse = "")
    return(print(output))
  }
}
is_docker()

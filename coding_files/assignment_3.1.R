# loading library
library(httr2)

# getting API_KEY varible from .credentials_exam.R file (so, I don't expose it)
source("exam_folder/.credentials_exam.R")

# making a request
req <- request("https://mdblist.p.rapidapi.com/") %>%
  req_url_query(s = "Christmas") %>%
  req_headers(
    'Accept' = 'application/json',
    'Content-Type' = 'application/json',
    'x-rapidapi-ua' = 'RapidAPI-Playground',
    'X-RapidAPI-Key' = API_KEY, # using the API_KEY variable from .credentials_exam.R file
    'X-RapidAPI-Host' = 'mdblist.p.rapidapi.com'
  )

resp <- req %>% 
  req_perform()

# Parse JSON response
result <- resp %>%
  resp_body_json()

print(result$search[[1]]$title)
print(result$search[[1]]$id)

#Output:
#> print(result$search[[1]]$title)
#[1] "The Nightmare Before Christmas"
#> print(result$search[[1]]$id)
#[1] "tt0107688"
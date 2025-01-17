library(httr2)
library(jsonlite)

key = readLines("openai_key.txt")

req = request("https://api.openai.com/v1/images/generations") |>
  req_headers(
    "Content-Type" = "application/json",
    "Authorization" = paste0("Bearer ", key)
  ) |>
  req_body_json(list(
    model = "dall-e-3",
    prompt = "A team of communication researchers using digital research methods and computational methods, cyberpunk style",
    n = 1,
    size = "1024x1024"
  )) |>
  req_perform()

image_url = resp_body_json(req)$data[[1]]$url
download.file(url = image_url, destfile = "as_digimeth.png")

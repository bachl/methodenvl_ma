library(httr)
library(jsonlite)

key = readLines("openai_key.txt")

url <- "https://api.openai.com/v1/images/generations"

headers <- c(
  "Content-Type" = "application/json",
  "Authorization" = paste0("Bearer ", key)
)

body <- list(
  model = "dall-e-3",
  prompt = "A team of communication researchers using digital research methods and computational methods, cyberpunk style",
  n = 1,
  size = "1024x1024"
)

response <- POST(url, body = toJSON(body, auto_unbox = TRUE), encode = "json", add_headers(.headers=headers))

download.file(url = content(response)$data[[1]]$url, destfile = "as_digimeth.png")

# $revised_prompt
# [1] "An ensemble of communication scholars, composed of individuals with different genders and descents such as Caucasian, Black, Asian, and Hispanic. They are seen in a high-tech room, engrossed in the process of using digital and computational research methods. Their style is reminiscent of cyberpunk aesthetic -- futuristic, with neon lights illuminating the room. Data and information streams can be seen flowing in the form of holographic displays. Everyone wears contemporary fashion infused with technology, providing a visual that bridges the gap between analog and digital domains."
# $url
# [1] "https://oaidalleapiprodscus.blob.core.windows.net/private/org-bbzGjIqjLwLppa6lHTzcAvHP/user-wP8HcHrjieqQxh0wxaOYgHMz/img-x5m01oTOqHS4ONcVcrFp55Ng.png?st=2024-01-11T13%3A25%3A45Z&se=2024-01-11T15%3A25%3A45Z&sp=r&sv=2021-08-06&sr=b&rscd=inline&rsct=image/png&skoid=6aaadede-4fb3-4698-a8f6-684d7786b067&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2024-01-11T02%3A28%3A42Z&ske=2024-01-12T02%3A28%3A42Z&sks=b&skv=2021-08-06&sig=QER2KO0yoMsNlvtBD3WFqAJBNyYzsVd6c0jqofiqkIs%3D"

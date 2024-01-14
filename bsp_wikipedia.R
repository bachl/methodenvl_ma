# Paktete ####
library(httr2) # Kommunikation mit API über HTTP
library(jsonlite) # JSON-Dateien
library(tidyverse) # Datenmanipulation und Grafik

# Anfrage erstellen ####
req = request(base_url = "https://de.wikipedia.org/w/api.php") |> 
  req_url_query(!!!list(
    action = "query",
    format = "json",
    prop = "pageviews",
    titles = c("Olaf_Scholz", "Robert_Habeck", "Christian_Lindner"),
    pvipdays = 21),
    .multi = "pipe")

# Anfrage testen ####
req |> 
  req_dry_run()

# Anfrage stellen ####
resp = req|> 
  req_perform()

# Antwort als Text ansehen ####
resp |> 
  resp_body_string() |> 
  prettify()

# Antwort in Datenformat konvertieren und plotten ####
resp |> 
  resp_body_json() |>
  _$query |> 
  _$pages |> 
  map_dfr(as_tibble) |> 
  mutate(date = as_date(names(pageviews))) |> 
  unnest(pageviews) |> 
  ggplot(aes(date, pageviews, color = title)) + 
  geom_line() + 
  theme_minimal()



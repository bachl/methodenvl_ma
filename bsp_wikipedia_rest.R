# Paktete ####
library(httr2) # Kommunikation mit API über HTTP
library(jsonlite) # JSON-Dateien
library(tidyverse) # Datenmanipulation und Grafik

# Anfrage erstellen ####
# Vorsichtig: bei req_url_path_append ist korrekte Reihenfolge
# der Parameter notwendig!
req = request(base_url = "https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/") |> 
  req_url_path_append(list(
    project = "de.wikipedia.org",
    access = "all-access",
    agent = "user",
    article = "Alice_Weidel",
    granularity = "daily",
    start = "20210101",
    end = "20250117"
  )
  )

# Anfrage testen ####
req |> 
  req_dry_run()

# Anfrage stellen ####
resp = req|> 
  req_perform()

# Antwort in Datenformat konvertieren und plotten ####
resp |> 
  resp_body_json() |> 
  _$items |> 
  map_dfr(as_tibble) |> 
  mutate(date = ymd(str_sub(timestamp, end = -3))) |> 
  ggplot(aes(date, views)) + 
  scale_y_continuous(labels = scales::number_format(scale = 1)) +
  geom_line() + 
  theme_minimal()

# Paktete ####
library(httr2) # Kommunikation mit API über HTTP
library(jsonlite) # JSON-Dateien
library(tidyverse) # Datenmanipulation und Grafik

# Key zur Anmeldung bei OpenAI ####
# Niemals öffentlich teilen!
key = readLines("openai_key.txt")

# API endpoint ####
req = request(base_url = "https://api.openai.com/v1/chat/completions")

# Anmeldung ####
req |> 
  req_auth_bearer_token(key)

# Prompt ####
# 1) Anweisung
instr = paste(readLines("instr_nodef_reason.txt"), collapse = "\n")
cat(instr)

# 2) Codiereinheiten
cod = readLines("comments.txt")
cat(cod, sep = "\n")

# Anfrage ####
req |> 
  req_auth_bearer_token(key) |> 
  req_body_json(list(
    model = "gpt-3.5-turbo",
    messages = list(
      list(role = "system", content = instr),
      list(role = "user", content = cod[1])
    ),
    temperature = 0,
    max_tokens = 50
  )) |> 
  req_dry_run()

# Antwort ####
resp = req |> 
  req_auth_bearer_token(key) |> 
  req_body_json(list(
    model = "gpt-3.5-turbo",
    messages = list(
      list(role = "system", content = instr),
      list(role = "user", content = cod[1])
    ),
    temperature = 0,
    max_tokens = 50
  )) |> 
  req_perform()

# Antwort als JSON ansehen ####
resp |> 
  resp_body_string() |> 
  prettify()

# Relevanten Teil der Antwort extrahieren ####
resp |> 
  resp_body_json() |> 
  _$choices |> 
  _[[1]] |> 
  _$message |> 
  _$content

# Anfragen für alle Kommentare ####
req_list = cod |> 
  map(~ {
    req |> 
      req_auth_bearer_token(key) |> 
      req_body_json(list(
        model = "gpt-3.5-turbo",
        messages = list(
          list(role = "system", content = instr),
          list(role = "user", content = .x)
        ),
        temperature = 0,
        max_tokens = 50
      ))
  })

# Antworten für alle Kommentare ####
resp_list = req_list |> 
  req_perform_parallel()

# Extrahieren und aufbereiten ####
tibble(
  Kommentar = cod,
  Klassifikation = resp_list |> 
    map_chr( ~ {
      .x |> 
        resp_body_json() |> 
        _$choices |> 
        _[[1]] |> 
        _$message |> 
        _$content
    })
) |> 
  knitr::kable()

# Pakete ####
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
# 1) Codieranweisung
instr = paste(readLines("codieranweisung.txt"), collapse = "\n")
cat(instr)

# 2) Kategorien
response_format = list(
  type = "json_schema",
  json_schema = list(
    name = "social_media_incivility",
    schema = list(
      type = "object",
      properties = list(
        reasoning = list(
          description = "Short text to explain your reasoning",
          type = "string"
        ),
        classification = list(
          description = "Classification into incivil or civil",
          type = "string",
          enum = c("incivil", "civil")
        )
      ),
      additionalProperties = FALSE,
      required = c("reasoning", "classification")
    )
  )
)
response_format |> 
  toJSON() |> 
  prettify()

# 3) Codiereinheiten
cod = readLines("comments.txt")
cat(cod, sep = "\n")

# Anfrage ####
req |> 
  req_auth_bearer_token(key) |> 
  req_body_json(list(
    model = "gpt-4o",
    messages = list(
      list(role = "system", content = instr),
      list(role = "user", content = cod[1])
    ),
    response_format = response_format,
    temperature = 0,
    max_completion_tokens = 500
  )) |> 
  req_dry_run()

# Antwort ####
resp = req |> 
  req_auth_bearer_token(key) |> 
  req_body_json(list(
    model = "gpt-4o",
    messages = list(
      list(role = "system", content = instr),
      list(role = "user", content = cod[1])
    ),
    response_format = response_format,
    temperature = 0,
    max_completion_tokens = 500
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
  _$content |> 
  prettify()

resp |> 
  resp_body_json() |> 
  _$choices |> 
  _[[1]] |> 
  _$message |> 
  _$content |> 
  fromJSON() |> 
  as_tibble()

# Anfragen für alle Kommentare ####
req_list = cod |> 
  map(~ {
    req |> 
      req_auth_bearer_token(key) |> 
      req_body_json(list(
        model = "gpt-4o",
        messages = list(
          list(role = "system", content = instr),
          list(role = "user", content = .x)
        ),
        response_format = response_format,
        temperature = 0,
        max_completion_tokens = 500
      )) 
  })

# Antworten für alle Kommentare ####
resp_list = req_list |> 
  req_perform_parallel()

# Extrahieren und aufbereiten ####
tibble(Kommentar = cod) |> 
  bind_cols(
    resp_list |> 
      map_dfr( ~ {
        .x |> 
          resp_body_json() |> 
          _$choices |> 
          _[[1]] |> 
          _$message |> 
          _$content |> 
          fromJSON() |> 
          as_tibble()
      })
  ) |> 
  knitr::kable()

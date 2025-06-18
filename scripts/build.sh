#!/bin/bash

# Konfiguracja
GITLAB_URL="https://gitlab.com/api/graphql"  # Zmień na swój adres GitLab, jeśli inny
# GITLAB_TOKEN="glpat-x..."                  # Ustaw swój token GitLab
OUTPUT_FILE="docs/containers.md"

# Zapytanie GraphQL
QUERY='{
  "query": "query { group(fullPath: \"pl.rachuna-net/containers\") { projects(includeSubgroups: true) { nodes { name fullPath description } } } }"
}'

# Wykonanie zapytania
RESPONSE=$(curl -s --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $GITLAB_TOKEN" \
  --data "$QUERY" \
  "$GITLAB_URL")

# Sprawdzenie błędów
if [[ -z "$RESPONSE" ]]; then
  echo "Błąd: Brak odpowiedzi z API GitLab." >&2
  exit 1
fi

# Nagłówek tabelki Markdown
{
  echo "| container | version | description |"
  echo "|-----------|---------|-------------|"

  # Parsowanie, sortowanie i generowanie tabelki
  echo "$RESPONSE" | jq -r '.data.group.projects.nodes | map(select(.name != "gitlab-profile")) | sort_by(.name)[] | "| [\(.name)](https://gitlab.com/\(.fullPath)) | ![](https://gitlab.com/\(.fullPath)/-/badges/release.svg) | \(.description) |"'
} > "$OUTPUT_FILE"

echo "Tabela Markdown została zapisana do pliku: $OUTPUT_FILE"

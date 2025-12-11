#!/usr/bin/env bash
set -euo pipefail

# --- CONFIGURATION ---
API_EMAIL="Rob@familysearch.org/token"
API_TOKEN=$ZENTOKEN
BASE_URL="https://familysearch.zendesk.com/api/v2/help_center"

IMPORT_LIST_PATH="$1"
if [[ -z "$IMPORT_LIST_PATH" || ! -f "$IMPORT_LIST_PATH" ]]; then
  echo "Usage: $0 <IMPORT_LIST_PATH>"
  exit 1
fi

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required but not installed"; exit 1; }

# Read input file line by line
while IFS= read -r FILEPATH; do
  # skip empty lines
  [[ -z "$FILEPATH" ]] && continue

  log "INFO: Processing $FILEPATH"

  # Extract locale and filename
  #  FILEPATH like …/.../<locale>/<id>--title.html
  LOCALE=$(basename "$(dirname "$FILEPATH")")
  BASENAME=$(basename "$FILEPATH")
  # get filename from article_id
  ARTICLE_ID="${BASENAME%%--*}"
  if [[ -z "$ARTICLE_ID" ]]; then
    log "ERROR: Cannot parse article_id from filename $BASENAME"
    continue
  fi

  # Read the HTML body
  if ! CONTENT=$(< "$FILEPATH"); then
    log "ERROR: Cannot read file $FILEPATH"
    continue
  fi

  # Escape JSON payload (body)
  JSON_BODY=$( jq -Rn --arg b "$CONTENT" '{ translation: { body: $b } }' )

  # Determine if translation exists: try GET first
  GET_URL="${BASE_URL}/articles/${ARTICLE_ID}/translations/${LOCALE}.json"
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -u "${API_EMAIL}:${API_TOKEN}" "$GET_URL")

  if [[ "$HTTP_STATUS" == "200" ]]; then
    # translation exists — use PUT to update
    log "INFO: Updating translation for article $ARTICLE_ID locale $LOCALE"
    RESP=$(curl -s -w "\nHTTP %{http_code}\n" -u "${API_EMAIL}:${API_TOKEN}" \
      -H "Content-Type: application/json" \
      -X PUT "${BASE_URL}/articles/${ARTICLE_ID}/translations/${LOCALE}.json" \
      -d "$JSON_BODY")
  else
    # translation missing — use POST to create
    log "INFO: Creating translation for article $ARTICLE_ID locale $LOCALE"
    ARTICLE_JSON=$(curl -s -u "${API_EMAIL}:${API_TOKEN}" \
        "${BASE_URL}/articles/${ARTICLE_ID}.json")

    TITLE=$(echo "$ARTICLE_JSON" | jq -r '.article.title')
    RESP=$(curl -s -w "\nHTTP %{http_code}\n" -u "${API_EMAIL}:${API_TOKEN}" \
      -H "Content-Type: application/json" \
      -X POST "${BASE_URL}/articles/${ARTICLE_ID}/translations.json" \
      -d "$( jq -Rn --arg t "$TITLE" --arg l "$LOCALE" --arg b "$CONTENT" '{ translation: { locale: $l, title: $t, body: $b } }' )")
  fi

  echo "$RESP"

done < "$IMPORT_LIST_PATH"

log "INFO: push.sh completed"

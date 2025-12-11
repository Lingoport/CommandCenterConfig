#!/bin/bash

set -euo pipefail

API_EMAIL="Rob@familysearch.org/token"
API_TOKEN=$ZENTOKEN
BASE_URL="https://familysearch.zendesk.com/api/v2/help_center"
LABEL="Volunteer_Translation"
PULL_TIME=$PULLDATE

WORKSPACES_DIR=$CLIENT_SOURCE_DIR

if [[ -z "$PULL_TIME" ]]; then
  echo "pull time not set"
  exit 1
fi


log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }


command -v jq >/dev/null 2>&1 || { echo "ERROR: jq not installed"; exit 1; }

log "INFO: Using workspace: $WORKSPACES_DIR"
mkdir -p "$WORKSPACES_DIR"

log "INFO: Fetching article list..."
JSON=$(curl -f -s -u "${API_EMAIL}:${API_TOKEN}" \
    "${BASE_URL}/articles.json?label_names=${LABEL}")

echo "$JSON" | jq -c '.articles[]' | while read -r article; do
    ID=$(echo "$article" | jq -r '.id')
    TITLE=$(echo "$article" | jq -r '.title')
    UPDATED_AT=$(echo "$article" | jq -r '.updated_at')

    if [[ "$UPDATED_AT" < "$PULL_TIME" ]]; then
        log "INFO: Skip $ID (updated_at=$UPDATED_AT before pullTime=$PULL_TIME)"
        continue
    fi

    log "INFO: Updating article $ID (updated_at=$UPDATED_AT)"

    SAFE_TITLE=$(echo "$TITLE" | tr ' /\\:*?"<>|' '_' | tr -d '\r\n')
    SAFE_TITLE=$(echo "$SAFE_TITLE" | sed 's/[^A-Za-z0-9._-]/_/g')

    FILENAME="${ID}--${SAFE_TITLE}.html"

    TRANS_JSON=$(curl -f -s -u "${API_EMAIL}:${API_TOKEN}" \
        "${BASE_URL}/articles/${ID}/translations.json") || {
            log "ERROR: cannot fetch locales for $ID"
            continue
        }

    echo "$TRANS_JSON" | jq -c '.translations[]' | while read -r tr; do
        LOCALE=$(echo "$tr" | jq -r '.locale')

        LOCALE_DIR="${WORKSPACES_DIR}/${LOCALE}"
        mkdir -p "$LOCALE_DIR"

        OUTPUT="${LOCALE_DIR}/${FILENAME}"

        CONTENT=$(curl -f -s -u "${API_EMAIL}:${API_TOKEN}" \
            "${BASE_URL}/articles/${ID}/translations/${LOCALE}.json") || {
                log "ERROR: failed to fetch translation for $ID $LOCALE"
                continue
            }

        BODY=$(echo "$CONTENT" | jq -r '.translation.body // empty')

        if [[ -z "$BODY" ]]; then
            log "WARN: empty body for $ID locale $LOCALE"
            continue
        fi

        echo "$BODY" > "$OUTPUT"

        log "INFO: Saved updated $OUTPUT"
    done
done

log "INFO: pull.sh completed"

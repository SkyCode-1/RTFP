#!/bin/bash

# Имя временного файла для записи изменений
CHANGESET_STATUS_FILE="changeset-changes.json"

# Имя переменной в которой будет записан "результат" выполнения
PUBLISH_VAR_NAME="SHOULD_PUBLISH"

# Если произойдет ошибка, выбросим ее во "вне" чтобы можно было отследить
function error_exit {
  # Выведем передаваемую ошибку и поместим ее в вывод внутри CI
  echo "Error: $1" >&2
  exit 1
}

if ! npx changeset status --output="$CHANGESET_STATUS_FILE"; then
  error_exit "Command 'npx changeset status' failed. Make sure Changeset is installed and configured."
fi

if [ ! -f "$CHANGESET_STATUS_FILE" ]; then
  error_exit "File '$CHANGESET_STATUS_FILE' not found after executing 'npx changeset status'. Check path and permissions."
fi

NUM_CHANGESETS=$(jq '.changesets | length' "$CHANGESET_STATUS_FILE")
NUM_RELEASES=$(jq '.releases | length' "$CHANGESET_STATUS_FILE")

if [ -z "$NUM_CHANGESETS" ] || [ -z "$NUM_RELEASES" ]; then
  error_exit "Unable to parse JSON file '$CHANGESET_STATUS_FILE' using jq. Please ensure that the JSON structure is correct."
fi

SHOULD_PUBLISH="false"

if [ "$NUM_CHANGESETS" -gt 0 ] || [ "$NUM_RELEASES" -gt 0 ]; then
  SHOULD_PUBLISH="true"
  echo "Changes or new releases detected."
else
  echo "No changes or new releases found."
fi

if [ -n "$GITHUB_OUTPUT" ]; then
  echo "$PUBLISH_VAR_NAME=$SHOULD_PUBLISH" >> "$GITHUB_OUTPUT"
fi

export "$PUBLISH_VAR_NAME"="$SHOULD_PUBLISH"

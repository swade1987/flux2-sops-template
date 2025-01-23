#!/bin/bash

function main {

  clear

  printf "Checking for unencrypted secrets in the 'secrets' directory ...\n\n"

  FILES=$(find secrets -type f -name "*.yaml")
  UNENCRYPTED_FILE_COUNT=0

  # Loop around each file increase the "UNENCRYPTED_FILE_COUNT" variable if the file is not encrypted.
  for file in $FILES; do

    if [ "${file}" = "templates/platform-system-gcr-registry-creds.yaml" ]; then
      continue
    fi

    # if file does not contain the word "sops" its not encrypted, therefore up the failure count.
    IS_ENCRYPTED=$(yq eval '.sops | has("version")' "${file}")

    if [ "${IS_ENCRYPTED}" != "true" ]; then
      printf "FAIL -- %s\n" "$file"
      ((UNENCRYPTED_FILE_COUNT=UNENCRYPTED_FILE_COUNT+1))
    else
      printf "OK -- %s\n" "$file"
    fi

  done

  if [ "${UNENCRYPTED_FILE_COUNT}" -ne 0 ]; then
    printf "\nFAILED -- %s file(s) were NOT encrypted.\n" "$UNENCRYPTED_FILE_COUNT"
    exit 1
  fi

  exit 0
}

main

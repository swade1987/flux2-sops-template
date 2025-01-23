#!/bin/bash

function get_clusters {
    for dir in secrets/* ; do
        echo -n "${dir##*/} "
    done
}

function decrypt_secrets {

    for secret in $(ag Secret "$secrets_dir" -l); do

      IS_ENCRYPTED=$(yq eval '.sops | has("version")' "${secret}")

      if [ "${IS_ENCRYPTED}" != "true" ]; then
        printf "SKIPPED - %s already decrypted.\n" "${secret}"
      else
        sops -d -i "$secret"
        printf "DECRYPTED - %s successfully decrypted.\n" "${secret}"
      fi

    done
}

# ======================================================================================================================

if [[ "$1" == "" ]]; then
    echo "Please provide an environment you want to seal (e.g. bh)"
    exit
fi

if ! which sops > /dev/null 2>&1; then
  echo 'Please install sops. On MacOS and Linux you can use "make initialise".'
  exit
fi

if ! which yq > /dev/null 2>&1; then
  echo 'Please install yq. On MacOS and Linux you can use "make initialise".'
  exit
fi

if ! which ag > /dev/null 2>&1; then
  echo 'Please install the_silver_searcher. On MacOS and Linux you can use "make initialise".'
  exit
fi

# Make sure you have the latest version of sops installed.
SOPS_VERSION_CHECK=$(sops --version | grep -c "3.6.1")
if [ "${SOPS_VERSION_CHECK}" -ne 1 ]; then
  echo 'Please install sops v3.6.1'
  exit 1
fi

# Set a variable to specify the environment we are working on.
clusters=$1

if [[ ${clusters} == "all" ]]; then
    clusters=$(get_clusters)
    printf "\nclusters contains: %s \n\n" "${clusters}"
fi

for cluster in ${clusters}; do

    secrets_dir="secrets/${cluster}"

    # Handle the case when the directory does not exist
    if [[ ! -e ${secrets_dir} ]]; then
      printf "The directory %s does not exist, skipping ... \n" "${secrets_dir}"
      continue
    fi

    # Handle the case when the directory is empty.
    if [[ $(ag Secret "$secrets_dir" -l  | wc -l ) -eq 0 ]]; then
       printf "The directory %s does not contain any secrets, skipping ... \n" "${secrets_dir}"
       continue
    fi

    decrypt_secrets
done

printf "\nAll clusters completed"

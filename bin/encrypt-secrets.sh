#!/bin/bash
function validation {
    validate_secret_name "$1" && validate_image_pull_secret "$1"
}

function validate_secret_name {
    FILE=$1

    NAME=$(yq e --unwrapScalar=false '.metadata.name' "$FILE")
    NAMESPACE=$(yq e --unwrapScalar=false '.metadata.namespace' "$FILE")

    if [[ ! $(basename "$FILE") == "${NAMESPACE}-${NAME}.yaml" ]]; then
        printf "WARN - Skipping secret %s; file name does not match <namespace>-<secret name>.yaml\n" "${secret}"
        return 1
    else
        return 0
    fi
}

function validate_image_pull_secret {
    FILE=$1

    if [[ $(basename "$FILE") == *"image-pull-secret.yaml" ]]; then
        TYPE=$(yq e --unwrapScalar=false '.type' "$FILE")
        if [[ "${TYPE}" != "kubernetes.io/dockerconfigjson" ]]; then
            printf "WARN - Skipping secret %s; image pull secrets must be of type kubernetes.io/dockerconfigjson\n" "${secret}"
            return 1
        fi
    fi
    return 0
}

function get_clusters {
    for dir in secrets/* ; do
        echo -n "${dir##*/} "
    done
}

function encrypt_secrets {

    for secret in $(ag Secret "$secrets_dir" -l); do

        if validation "${secret}"; then

          # Gracefully handle when secret has already been encrypted.
          IS_ENCRYPTED=$(yq eval '.sops | has("version")' "${secret}")

          if [ "${IS_ENCRYPTED}" != "true" ]; then
             # Use sops to encrypt the secret  with the same name.
            sops -e -i "$secret"
            printf "ENCRYPTED - %s successfully encrypted.\n" "${secret}"
          else
            printf "SKIPPED - %s already encrypted.\n" "${secret}"
          fi
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

    encrypt_secrets
done

printf "\nAll clusters completed"

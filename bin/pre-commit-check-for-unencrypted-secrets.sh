#!/bin/bash
set -e

function check_dependencies() {
    if ! command -v yq &> /dev/null; then
        echo "❌ Error: yq is not installed. Please install yq first."
        exit 1
    fi
}

function main {
    # Find all yaml files in secrets directory
    FILES=$(find secrets -type f -name "*.yaml" 2>/dev/null | sort -u)

    if [ -z "$FILES" ]; then
        echo "⚠️  Warning: No YAML files found in secrets directory"
        exit 0
    fi

    unencrypted_count=0
    UNENCRYPTED_FILES=""

    while IFS= read -r file; do
        IS_ENCRYPTED=$(yq eval '.sops | has("version")' "${file}")
        if [ "${IS_ENCRYPTED}" = "false" ]; then
            UNENCRYPTED_FILES+="   - $file"$'\n'
            ((unencrypted_count++))
        fi
    done <<< "$FILES"

    if [ $unencrypted_count -gt 0 ]; then
        echo "❌ Error: Found $unencrypted_count unencrypted secret file(s):"
        echo
        echo -n "$UNENCRYPTED_FILES"
        echo "Please encrypt these files using SOPS before committing."
        exit 1
    fi

    echo "✅ All secret files are properly encrypted!"
    exit 0
}

# Check for required dependencies
check_dependencies

# Run main function
main

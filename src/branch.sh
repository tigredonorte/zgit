#!/bin/bash

display_help() {
    echo "Create a new branch based on the current branch."
    echo "usage zgit branch <slug>"
}

branch_exists() {
    local base_branch_name="$1"
    local slug="$2"
    local counter=0

    # Check if a branch matching the pattern CPF-850-3-{0..n}-some-slug exists
    while git show-ref --verify --quiet refs/heads/"${base_branch_name}-${counter}-${slug}"; do
        ((counter++))
    done

    # Return 0 (true) if a matching branch is found, 1 (false) otherwise
    return $((counter > 0 ? 0 : 1))
}

main() {
    # The slug should be assigned before it's used
    local slug="$1"

    if [[ -z $slug ]]; then
        echo -e "Slug is required. \n"
        display_help
        exit 1
    fi

    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    local next_branch_name
    if [[ "$current_branch" == "main" ]]; then
        next_branch_name="${slug}"
        if branch_exists "$current_branch" "$slug"; then
            echo "A branch with slug ${slug} already exists. Aborting."
            exit 1
        fi
    else
        next_branch_name="${current_branch}-1-${slug}"
        if branch_exists "$current_branch" "$slug"; then
            echo "A branch matching the pattern ${current_branch}-{0..n}-${slug} already exists. Aborting."
            exit 1
        fi
    fi

    git branch "$next_branch_name"
    git checkout "$next_branch_name"
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi

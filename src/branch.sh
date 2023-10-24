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

    if branch_exists "$current_branch" "$slug"; then
        echo "A branch matching the pattern ${current_branch}-{0..n}-${slug} already exists. Aborting."
        exit 1
    fi

    # If no matching branch is found, create a new branch
    local next_branch_name="${current_branch}-1-${slug}"
    git branch "$next_branch_name"
    git checkout "$next_branch_name"

    # Update the PR name with the slug
    # ... (you would need to implement the logic for updating the PR name here)
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi

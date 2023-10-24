#!/bin/bash

display_help() {
    echo "Checkout the parent branch."
}

get_parent_branch_name() {
    local current_branch="$1"
    local parent_branch

    # Split the current branch name into its components
    if [[ $current_branch =~ (.+)-[0-9]+(-.*)?$ ]]; then
        parent_branch=${BASH_REMATCH[1]}
    else
        echo "Invalid branch name format."
        exit 1
    fi

    echo "$parent_branch"
}

checkout_parent_branch() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local parent_branch=$(get_parent_branch_name "$current_branch")

    # Ensure the parent branch exists
    if ! git show-ref --verify --quiet refs/heads/"$parent_branch"; then
        echo "Parent branch $parent_branch does not exist."
        exit 1
    fi

    # Checkout the parent branch
    git checkout "$parent_branch"
}

main() {
    checkout_parent_branch
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi

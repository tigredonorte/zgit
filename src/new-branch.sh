#!/bin/bash

display_help() {
    echo "Usage: new-branch <branch-name>"
    echo
    echo "Creates a new branch from origin/main with the specified name."
}

main() {
    local branch_name="$1"
    
    if [[ -z $branch_name ]]; then
        echo "Branch name is required."
        display_help
        exit 1
    fi

    # Fetch the latest changes from origin
    git fetch origin

    # Check if the branch name already exists
    if git show-ref --verify --quiet refs/heads/"$branch_name"; then
        echo "A branch named '$branch_name' already exists. Aborting."
        exit 1
    fi

    # Create the new branch from origin/main
    git branch "$branch_name" origin/main
    git checkout "$branch_name"
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi

#!/bin/bash

# Function to display help information
display_help() {
    echo "Usage: cascade"
    echo
    echo "Cascade creates a new branch for each commit on the main branch,"
    echo "excluding the first commit. Before executing, it syncs up to the"
    echo "main branch using the syncUp script."
    echo
    echo "Options:"
    echo "  --help    Display this help message and exit."
}

# Function to sync up to the main branch
sync_up() {
    while : ; do
        local current_branch=$(git rev-parse --abbrev-ref HEAD)
        [[ "$current_branch" == "main" ]] && break
        ./src/syncUp.sh
    done
}

# Function to create branches for each commit on main
cascade_branches() {
    local commits=$(git log --oneline main | tail -n +2 | awk '{print $1}')
    for commit in $commits; do
        local commit_msg=$(git log --format=%B -n 1 $commit | head -n 1 | sed 's/ /-/g')
        local branch_name="cascade-$commit-$commit_msg"
        git branch "$branch_name" "$commit"
    done
}

# Main function to coordinate the script execution
main() {
    if [[ "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    sync_up
    cascade_branches
}

# Call the main function with all script arguments
main "$@"

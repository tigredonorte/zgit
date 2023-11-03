#!/bin/bash

source "$(dirname "$0")/helpers/get_prefix.sh"
source "$(dirname "$0")/syncUp.sh"

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
        update_from_parent
    done
}

create_slug() {
    local commit=$1
    local slug=$(git log --format=%B -n 1 $commit | head -n 1 | awk '{print $1"-"$2"-"$3}')
    echo $slug
}

# Function to create branches for each commit on main
cascade_branches() {
    local commits=$(git log --oneline main | tail -n +2 | awk '{print $1}')
    for commit in $commits; do
        local slug=$(create_slug $commit)
        local prefix=$(get_prefix "cascade")
        local branch_name="${prefix}$commit-$slug"
        # git branch "$branch_name" "$commit"
        echo -e "$branch_name" "$commit \n"
    done
}
# Main function to coordinate the script execution
main() {
    if [[ "$1" == "--help" ]]; then
        display_help
        exit 0
    fi

    sync_up
    # cascade_branches
}

# Call the main function with all script arguments
main "$@"

#!/bin/bash

source "$(dirname "$0")/helpers/get_children.sh"
source "$(dirname "$0")/helpers/get_prefix.sh"

display_help() {
    echo "Rebase the current branch and its children on origin/main."
    echo "Options:"
    echo "  --continue    Continue a rebase in progress."
    echo "  --abort       Abort a rebase in progress."
}

# Function to perform the rebase
rebase_branches() {
    local base_branch="$1"

    # Fetch the latest changes from origin/main
    git fetch origin main

    # Rebase the current branch
    git rebase origin/main

    # Get the list of child branches
    local child_branches=$(git for-each-ref --format '%(refname:short)' refs/heads | grep "^${base_branch}-[0-9]\+")

    for child_branch in $child_branches; do
        git checkout "$child_branch"
        git rebase "$base_branch"

        # Recursively rebase grandchild branches
        rebase_branches "$child_branch"
    done
}

main() {
    # if [[ "$1" == "--continue" ]]; then
    #     git rebase --continue
    # elif [[ "$1" == "--abort" ]]; then
    #     git rebase --abort
    # else
    #     local current_branch=$(git rev-parse --abbrev-ref HEAD)
    #     rebase_branches "$current_branch"
    #     git push origin +HEAD
    # fi

    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local prefix=$(get_prefix "$current_branch")
    local childrens=$(get_childrens "$prefix" "$current_branch")
    local children_list=$(echo "$childrens" | tac)

    echo "$children_list"
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi

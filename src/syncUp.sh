#!/bin/bash

source "$(dirname "$0")/helpers/get_parents.sh"

display_help() {
    echo "Rebase the current branch with the parent branch."
}

update_parents() {
    local parent_list="$1"
    local previous_branch="origin/main"  # Initialize with origin/main for the first rebase

    echo "$parent_list" | while IFS= read -r branch; do
        git checkout "$branch"

        # Rebase the current branch with the previous one
        git rebase "$previous_branch"

        # Check the exit status of the rebase command
        if [[ $? -ne 0 ]]; then
            echo "Rebase conflicts detected on branch $branch. Resolve the conflicts manually, then continue with git rebase --continue or abort with git rebase --abort."
            exit 1
        fi

        # Set the previous branch for the next iteration
        previous_branch="$branch"
    done <<< "$parent_list"  # Feed the reversed list of branches into the loop
}

main() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local parent_branches=$(get_parents "$current_branch")
    local parent_list=$(echo "$parent_branches" | tac)
    update_parents "$parent_list"
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi


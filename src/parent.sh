#!/bin/bash

display_help() {
    echo "Find the parent branches of all local branches."
}

# Function to find the parent branch of a given branch
parent_branch() {
    local branch_to_test="${1}"
    local other_branch
    local common_ancestor
    local latest_common_ancestor_commit=""
    local parent_branch=""
    
    # Get all branch names except the given branch
    local branches=$(git for-each-ref --format '%(refname:short)' refs/heads | grep -v "^${branch_to_test}$")
    
    for other_branch in $branches; do
        # Find common ancestor of the given branch and the other branch
        common_ancestor=$(git merge-base "$branch_to_test" "$other_branch")
        
        # If this common ancestor is more recent than the latest found, update the latest and the parent branch
        if [[ -z "$latest_common_ancestor_commit" || $(git rev-list --count "$latest_common_ancestor_commit".."$common_ancestor") -gt 0 ]]; then
            latest_common_ancestor_commit="$common_ancestor"
            parent_branch="$other_branch"
        fi
    done

    # Check if the parent branch is main
    if [[ "$parent_branch" == "main" ]]; then
        echo "$branch_to_test -> main"
    else
        echo "$branch_to_test -> $parent_branch"
    fi
}

# Function to find the parent branches of all local branches
all_branches_parents() {
    # Get all local branch names
    local branches=$(git for-each-ref --format '%(refname:short)' refs/heads)
    
    for branch in $branches; do
        parent_branch "$branch"
    done
}

main() {
    # Call the function to get the parent branches of all local branches
    all_branches_parents
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi

source "$(dirname "$0")/helpers/get_prefix.sh"

get_parents() {
    local current_branch="$1"

    local prefix=$(get_prefix "$current_branch")
    # Extract the base branch name by removing any sub-branch numbers and slugs
    local base_branch_name=$(echo "$current_branch" | sed -E 's/([^-]*-[^-]*).*/\1/')

    # Get a list of parent branches by filtering on the base branch name
    local parent_branches=$(git branch | grep -E "^  $base_branch_name" | grep -Ev "^  $prefix" | sed 's/^[* ] //')

    # Append main to the list of parent branches
    parent_branches=$(echo -e "$current_branch\n$parent_branches\nmain")
  
    echo "$parent_branches"
}

get_parent() {
    local current_branch="$1"
    local parent_branches=$(get_parents "$current_branch")
    local first_parent=$(echo "$parent_branches" | sed -n '2p')
    echo "$first_parent"
}
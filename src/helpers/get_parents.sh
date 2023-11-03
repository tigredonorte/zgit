source "$(dirname "$0")/helpers/get_prefix.sh"

get_parents() {
    local current_branch="$1"

    local prefix=$(get_prefix "$current_branch")
    local base_branch_name=$(get_parent_prefix "$current_branch")

    local parent_branches=$(git branch | grep -E "^  $base_branch_name" | grep -v "$prefix" | grep -Ev "$base_branch_name[0-9]+-" | sed 's/^[* ] //')

    children_number=$(echo "$prefix" | sed -E 's/.*-([0-9]+)-$/\1/')

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
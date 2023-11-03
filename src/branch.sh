#!/bin/bash

source "$(dirname "$0")/helpers/get_prefix.sh"
source "$(dirname "$0")/helpers/get_children.sh"

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

get_next_child_number() {
    local prefix=$1
    local current_branch=$2
    local children=$(get_children "$prefix" "$current_branch")
    local max_child_number=0
    local children_number

    for child_branch in $children; do
        children_prefix=$(get_prefix $child_branch)
        children_number=$(echo "$children_prefix" | sed -E 's/.*-([0-9]+)-$/\1/')

        if ! [[ $children_number =~ ^[0-9]+$ ]]; then
            echo "Error: children_number is not a number. Received: '$children_number'" >&2
            exit 1
        fi

        if [[ $children_number -gt $max_child_number ]]; then
            max_child_number=$children_number
        fi
    done

    # Increment max_child_number to get the next child number
    echo $((max_child_number + 1))
}

get_children_branch_name() {
    local current_branch=$1
    local slug=$2
    local next_branch_name
    if [[ "$current_branch" == "main" ]]; then
        next_branch_name="${slug}"
        if branch_exists "$current_branch" "$slug"; then
            echo "A branch with slug ${slug} already exists. Aborting."
            exit 1
        fi
    else
        local prefix=$(get_prefix $current_branch)
        local child_number=$(get_next_child_number $prefix $current_branch)
        
        next_branch_name="${prefix}${child_number}-${slug}"

        if branch_exists "${prefix}${child_number}" "$slug"; then
            echo "A branch matching the pattern ${current_branch}-{0..n}-${slug} already exists. Aborting."
            exit 1
        fi
    fi

    echo "$next_branch_name"
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
    local next_branch_name=$(get_children_branch_name "$current_branch" "$slug")
    

    echo "Creating branch '${next_branch_name}' based on '${current_branch}'"
    git checkout -B "$next_branch_name"
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi

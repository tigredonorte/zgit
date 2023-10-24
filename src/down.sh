#!/bin/bash

display_help() {
    echo "Switch to a child branch if only one exists, otherwise list the children and allow selection."
}

list_children() {
    local current_branch="$1"
    git branch --list | grep -E "^  ${current_branch}-[0-9]+"
}

checkout_child_branch() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local children=$(list_children "$current_branch")

    if [[ $(echo "$children" | wc -l) -eq 1 ]]; then
        # If there's only one child, checkout that branch
        git checkout $(echo "$children" | awk '{print $1}')
    elif [[ $(echo "$children" | wc -l) -gt 1 ]]; then
        # If there are multiple children, display a menu to select one
        echo "Multiple child branches found. Please select one:"
        select child in $children; do
            if [[ -n $child ]]; then
                git checkout $child
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done
    else
        echo "No child branches found."
    fi
}

main() {
    checkout_child_branch
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi

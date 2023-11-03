#!/bin/bash

# Function to display usage
display_help() {
    echo "Usage: zgit commit [commit message]"
    echo "If no commit message is provided, the last commit will be amended."
}

# Main function to handle the commit process
main() {
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Please install git and try again."
        exit 1
    fi

    # Get the commit message from the first script argument, if provided
    local commit_message="$1"

    # Get the current branch name
    local branch_name=$(git rev-parse --abbrev-ref HEAD)

    # Extract the JIRA task number from the branch name
    local jira_task=$(echo $branch_name | grep -o '[A-Z]\+-[0-9]\+')

    # Check for staged changes
    local staged_changes=$(git diff --cached --quiet; echo $?)
    # If there are no staged changes, add all changes to the staging area
    if [[ "$staged_changes" -eq 0 ]]; then
        git add -A
    fi

    # Commit the changes
    if [[ -n "$commit_message" ]]; then
        # If JIRA task is found, prepend it to the commit message
        if [[ -n "$jira_task" ]]; then
            git commit -m "${jira_task}: ${commit_message}"
        else
            git commit -m "${commit_message}"
        fi
    else
        git commit --amend --no-edit
    fi

    # Push the changes
    git push origin +HEAD
}

# If the script is called with a function name, execute that function
if [[ -n $1 ]] && declare -F "$1" > /dev/null; then
    "$@"
fi


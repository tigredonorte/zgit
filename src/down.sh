#!/bin/bash

source "$(dirname "$0")/helpers/get_prefix.sh"
source "$(dirname "$0")/helpers/get_children.sh"

# Help function to display what the script does
display_help() {
    echo "Usage: zgit down"
    echo ""
    echo "This command checks the current branch name, fetches all local branch names, and finds all branches"
    echo "that share a common prefix with the current branch, excluding the current branch itself."
    echo ""
}

select_branch() {
    local branches=$1
    if [[ $(echo "$branches" | wc -l) -eq 1 ]]; then
        echo "$branches" | awk '{print $1}'
    elif [[ $(echo "$branches" | wc -l) -eq 0 ]]; then
        echo "No child branches found."
    else
        # If there are multiple children, display a menu to select one
        # Create an array to pass to dialog
        local branches_array=()
        while IFS= read -r branch; do
            branches_array+=("$branch" "")
        done <<< "$branches"
        # Use dialog to create a menu
        local selected_branch=$(dialog --clear \
            --title "Branch Selection" \
            --menu "Multiple child branches found. Please select one:" \
            15 60 10 \
            "${branches_array[@]}" \
            2>&1 >/dev/tty)
        # Clear the dialog screen
        reset
        echo "$selected_branch"
    fi
}

checkout() {
    local current_branch=$1
    local selected_branch=$2

    # Ensure both branches are up to date
    git fetch

    # Checkout the selected branch
    git checkout "$selected_branch"

    echo -e "Switched from $current_branch to $selected_branch. \n"
}

rebase() {
    local current_branch=$1
    local selected_branch=$2

    # Attempt to rebase the parent branch onto the selected branch
    git rebase "$current_branch"

    # Check the exit status of the rebase command
    if [[ $? -eq 0 ]]; then
        # If the exit status is 0, the rebase was successful
        echo -e "Rebase successful. Now on branch $selected_branch with the changes from $current_branch. \n"

     else
        # If the exit status is non-zero, there were conflicts
        echo -e "Rebase conflicts detected. \n"

        # Create an array to pass to dialog
        local options=("Resolve Conflicts" "Abort Rebase")
        local decision=$(dialog --clear \
            --title "Rebase Conflict" \
            --menu "Do you want to resolve the conflicts manually or abort the rebase?" \
            10 60 2 \
            "${options[0]}" "" \
            "${options[1]}" "" \
            2>&1 >/dev/tty)
        # Clear the dialog screen
        reset

        # Handle the user's decision
        case $decision in
            "${options[0]}")
                echo "Please resolve conflicts manually, then run 'git rebase --continue' to finish the rebase."
                ;;
            "${options[1]}")
                git rebase --abort
                echo "Rebase aborted. You remain on branch $current_branch."
                ;;
            *)
                echo "No action taken. You can run 'git rebase --abort' to abort the rebase or resolve conflicts manually."
                ;;
        esac
    fi
}

# Main function to execute everything
main() {
    # Get the current branch name
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # If on main, just inform the user and return
    if [[ $current_branch == "main" ]]; then
        echo "This is main, you can't down from here"
        return
    fi
    
    # Fetch all local branch names
    git fetch
    
     # Get the correct prefix from the current branch name
    prefix=$(get_prefix $current_branch)
    
    # Get matching branches
    matching_branches=$(get_children $prefix $current_branch)
    selected_branch=$(select_branch "$matching_branches")
    if [[ -n $selected_branch ]]; then
        checkout $current_branch $selected_branch
    else
        echo "No branch selected or found."
    fi

}

# If the script is called with a --help or -h flag, display help. Otherwise, run main.
if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
    display_help
else
    main
fi

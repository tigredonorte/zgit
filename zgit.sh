#!/bin/bash

script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
script_dir="$script_dir/src"

display_help() {
    echo "Usage: zgit <command> [options]"
    echo
    echo -e "Available commands:\n"
    for script in "$script_dir"/*.sh; do
        command=$(basename "$script" .sh)
        help_text=$(bash "$script" display_help)
        echo -e "  $command    $help_text \n"
    done
}

# Ensure the command is provided
if [[ -z $1 ]]; then
    echo "Error: No command provided"
    display_help
    exit 1
fi

# Get the command and shift the arguments
command=$1
shift

script="$script_dir/$command.sh"

if [[ -x "$script" ]]; then
    # If the script exists and is executable, run its main function with all remaining arguments
    bash "$script" main "$@"
else
    # If no matching script is found, display an error message and the help
    echo "Error: Unknown command '$command'"
    display_help
    exit 1
fi

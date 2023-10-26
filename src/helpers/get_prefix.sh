# Function to extract the correct prefix from the current branch name
get_prefix() {
    local branch=$1
    local prefix=$(echo $branch | grep -o '^[^-]*\(-[0-9]*\)*')
    # Check if the last character of the prefix is not a hyphen
    if [[ ${prefix: -1} != "-" ]]; then
        prefix="$prefix-"
    fi
    echo $prefix
}
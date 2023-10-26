get_children() {
    local prefix=$1
    local current_branch=$2
    git branch | grep -E "^  $prefix[0-9]*-" | grep -Fxv "* $current_branch" | grep -Ev "$prefix[0-9]*-.[0-9]*-" | sed 's/^[ \t]*//'
}
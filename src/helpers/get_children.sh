get_children() {
    local prefix=$1
    local current_branch=$2
    git branch | grep -E "^  $prefix[0-9]*-" | grep -Fxv "* $current_branch" | grep -Ev "$prefix[0-9]*-.[0-9]*-" | sed 's/^[ \t]*//'
}

get_childrens() {
    local prefix=$1
    local current_branch=$2
    local parent_branches=$(git branch | grep -E "^  $base_branch_name" | grep -Ev "^  $prefix" | sed 's/^[* ] //')

    git branch | grep -E "^  $prefix[0-9]*-" | grep -Fxv "* $current_branch" | sed 's/^[ \t]*//'
}
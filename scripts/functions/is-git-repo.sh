is_git_repo() {
  [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) = "true" ]]
}

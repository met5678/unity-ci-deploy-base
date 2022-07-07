is_gh_repo() {
  git remote get-url origin 2>/dev/null | grep git@github.com 1>/dev/null
}

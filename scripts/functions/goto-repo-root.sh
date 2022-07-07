goto_repo_root() {
  cd $(git rev-parse --show-toplevel)
}
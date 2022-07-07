create_gh_repo () {
  DIRNAME=${PWD##*/}
  VISIBILITY=${1:-"public"}
  ORG=${2:-"personal"}

  REPO="$DIRNAME"

  # if [[ -z $ORG ]]; then
  if [[ $ORG != "personal" ]]; then
    REPO="$ORG/$REPO"
  fi

  if [[ $VISIBILITY == "public" ]]; then
    echo "gh repo create $REPO --push --public"
  else
    echo "gh repo create $REPO --push --private"
  fi
}
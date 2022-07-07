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
    gh repo create $REPO --source=. --public
  else
    gh repo create $REPO --source=. --private
  fi
}
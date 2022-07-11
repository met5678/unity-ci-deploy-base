echo "-- Unity Project Setup Tool for Deployment to S3 --"

if is_git_repo; then
  goto_repo_root
fi

if is_unity_project; then
  echo "We're in a Unity project, great!"
else
  echo "ERROR: Not in a Unity project directory"
  exit 1
fi

IS_NEW_REPO=false

if is_git_repo; then
  echo "We are in a git repo, great!"
  if [[ $(git diff --cached) ]]; then
    echo "There are staged changes in this repo. Please commit or reset them, then try again."
    exit 1
  fi
else
  echo "We're not in a git repo, initializing one..."
  git init
  IS_NEW_REPO=true
fi

DID_MAKE_CHANGES=false

echo "Downloading Unity .gitignore";
curl -s https://raw.githubusercontent.com/github/gitignore/main/Unity.gitignore > .gitignore
echo "Downloading Unity .gitattributes";
curl -s https://gist.githubusercontent.com/webbertakken/ff250a0d5e59a8aae961c2e509c07fbc/raw/b767c9c8762a2cf4823de43d3ec649379d8ad064/.gitattributes > .gitattributes

if [[ $(git status --porcelain .gitignore .gitattributes) ]]; then 
  git add .gitignore .gitattributes 1>/dev/null
  echo "Committing .gitignore, .gitattributes to repo"
  git commit -m "Adding .gitignore, .gitattributes to project" 1>/dev/null
  DID_MAKE_CHANGES=true
fi

mkdir -p .github/workflows
echo "Downloading Github workflow for activation"
curl -s https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/activation.yml > .github/workflows/activation.yml
echo "Downloading Github workflow for deploy"
curl -s https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/build-deploy.yml > .github/workflows/build-deploy.yml

if [[ $(git status --porcelain .github/workflows) ]]; then 
  git add .github/workflows
  echo "Committing workflows to repo"
  git commit -m "Setting up unity project with CI" 1>/dev/null
  DID_MAKE_CHANGES=true
fi

if [[ "$IS_NEW_REPO" == "true" ]]; then
  git add .
  git commit -m "Initial commit for Unity project files" 1>/dev/null
  DID_MAKE_CHANGES=true
fi

if is_gh_repo; then
  echo "This repo is already on Github"
else
  echo "Not currently in a github repo. Let's create one together!"
  echo "Do you want a public or private repo?"
  PS3="Enter number of your choice: "
  select REPO_VISIBILITY in public private
  do
    if [[ "$REPO_VISIBILITY" = "private" || "$REPO_VISIBILITY" = "public" ]]; then
      break
    else
      echo "Invalid entry, try again"
    fi
  done

  echo "Do you want to make this repo in the roo-makes org or on your personal account?"
  PS3="Enter number of your choice: "
  select REPO_LOCATION in roo-makes personal
  do
    if [[ "$REPO_LOCATION" = "roo-makes" || "$REPO_LOCATION" = "personal" ]]; then
      break
    else
      echo "Invalid entry, try again"
    fi
  done

  create_gh_repo $REPO_VISIBILITY $REPO_LOCATION
fi

if [[ "$DID_MAKE_CHANGES" == "false" && "$IS_NEW_REPO" == "false" ]]; then
  echo "No changes made, exiting."
  exit 0
fi

while true; do
    read -p "Push these changes to github? (y/n) " yn
    case $yn in
        [Yy]* ) git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD); break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
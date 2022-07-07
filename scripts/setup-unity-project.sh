if is_git_repo; then
  goto_repo_root
fi

if is_unity_project; then
  echo "We're in a Unity project, great!"
else
  echo "ERROR: Not in a Unity project directory"
  exit 1
fi

if is_git_repo; then
  echo "We are in a git repo, great!"
else
  echo "We're not in a git repo, initializing one..."
  git init
fi

git stash

curl https://raw.githubusercontent.com/github/gitignore/main/Unity.gitignore > .gitignore
curl https://gist.githubusercontent.com/webbertakken/ff250a0d5e59a8aae961c2e509c07fbc/raw/b767c9c8762a2cf4823de43d3ec649379d8ad064/.gitattributes > .gitattributes

git add .gitignore .gitattributes
git commit -m "Adding .gitignore, .gitattributes to project"

mkdir -p .github/workflows
curl https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/activation.yml > .github/workflows/activation.yml
curl https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/build-deploy.yml > .github/workflows/build-deploy.yml
git add .github/workflows
git commit -m "Setting up unity project with CI"

git stash apply

git add .
git commit -m "Initial commit for Unity project files"

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

while true; do
    read -p "Push these changes to github? (y/n) " yn
    case $yn in
        [Yy]* ) git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD); break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
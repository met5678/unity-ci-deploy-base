#!/bin/sh


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


goto_repo_root() {
  cd $(git rev-parse --show-toplevel)
}


invalidate_cloudfront_for_bucket() {
  BUCKET=$1
  PATHS=/${2:-*}

  if [[ -z $BUCKET ]]; then
    echo "Error: No bucket specified to invalidate"
    return 1
  fi

  NUM_DISTROS=0

  for id in $(aws cloudfront list-distributions --query "DistributionList.Items[*].{id:Id,origin:Origins.Items[0].DomainName}[?starts_with(origin,'$BUCKET.s3.')].id" --output text);
  do
    echo "Invalidating \"$PATHS\" on Cloudfront Distribution: $id"
    INVAL_ID=$(aws cloudfront create-invalidation --distribution-id $id --paths "$PATHS" --query "Invalidation.Id" --output text)
    echo "Invalidation accepted: $INVAL_ID"
    ((NUM_DISTROS++))
  done

  echo "Invalidated $NUM_DISTROS distributions"
}


is_gh_repo() {
  git remote get-url origin 2>/dev/null | grep git@github.com 1>/dev/null
}



is_git_repo() {
  [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) = "true" ]]
}



is_unity_project() {
  [[ -d "Assets" && -d "ProjectSettings" ]]
}



update_build_deploy_platforms() {
  local FILE=".github/workflows/build-deploy.yml"
  local TEMP_FILE
  TEMP_FILE="$(mktemp)"

  local FOUND_TARGET_PLATFORM=false
  local IN_TARGET_BLOCK=false

  if [[ ! -f "$FILE" ]]; then
    echo "ERROR: $FILE does not exist. Cannot update targetPlatform."
    exit 1
  fi

  echo "Updating targetPlatform in $FILE..."

  while IFS= read -r line; do

    # If we encounter the targetPlatform line, mark it and write it out
    if [[ "$line" =~ targetPlatform: ]]; then
      FOUND_TARGET_PLATFORM=true
      IN_TARGET_BLOCK=true

      echo "$line" >> "$TEMP_FILE"
      # Immediately inject the newly selected lines
      echo "$PLATFORM_LINES" >> "$TEMP_FILE"
      continue
    fi

    # If we're in the block, skip old platforms and skip empty lines
    if $IN_TARGET_BLOCK; then
      # Skip lines like '        - Something'
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]] ]]; then
        continue
      fi

      # Also skip purely empty lines to avoid double-blank lines
      if [[ -z "${line// }" ]]; then
        # If it's blank or all whitespace, skip it
        continue
      fi

      # If we hit a line that doesn't match the dash pattern or blank,
      # that means we're out of the targetPlatform block.
      IN_TARGET_BLOCK=false
    fi

    # Write out lines that aren't skipped
    echo "$line" >> "$TEMP_FILE"
  done < "$FILE"

  # If we never found targetPlatform, append a new section
  if ! $FOUND_TARGET_PLATFORM; then
    echo "Didn't find 'targetPlatform:' in $FILE; appending a new matrix block."
    cat <<EOF >> "$TEMP_FILE"

strategy:
  fail-fast: false
  matrix:
    targetPlatform:
$PLATFORM_LINES
EOF
  fi

  mv "$TEMP_FILE" "$FILE"
  echo "Done updating $FILE."
}





echo "-- Unity Project Setup Tool for Automated Github Action Builds & Deployment to S3 --"

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

if [[ -f ".gitignore" ]]; then
  read -r -p ".gitignore already exists. Overwrite with a default one? [y/N] " answer
  case "$answer" in
    [Yy]* ) 
      echo "Downloading Unity .gitignore"
      curl -s https://raw.githubusercontent.com/github/gitignore/main/Unity.gitignore > .gitignore
      echo "Overwrote .gitignore."
      ;;
    * )
      echo "Skipping .gitignore overwrite."
      ;;
  esac
else
  curl -s https://raw.githubusercontent.com/github/gitignore/main/Unity.gitignore > .gitignore
  echo "Created a new .gitignore."
fi

if [[ -f ".gitattributes" ]]; then
  read -r -p ".gitattributes already exists. Overwrite with a default one? [y/N] " answer
  case "$answer" in
    [Yy]* )
      echo "Downloading Unity .gitattributes"
      curl -s https://gist.githubusercontent.com/webbertakken/ff250a0d5e59a8aae961c2e509c07fbc/raw/b767c9c8762a2cf4823de43d3ec649379d8ad064/.gitattributes > .gitattributes
      echo "Overwrote .gitattributes."
      ;;
    * )
      echo "Skipping .gitattributes overwrite."
      ;;
  esac
else
  curl -s https://gist.githubusercontent.com/webbertakken/ff250a0d5e59a8aae961c2e509c07fbc/raw/b767c9c8762a2cf4823de43d3ec649379d8ad064/.gitattributes > .gitattributes
  echo "Created a new .gitattributes."
fi

if [[ $(git status --porcelain .gitignore .gitattributes) ]]; then 
  git add .gitignore .gitattributes 1>/dev/null
  echo "Committing .gitignore, .gitattributes to repo"
  git commit -m "Adding .gitignore, .gitattributes to project" 1>/dev/null
  DID_MAKE_CHANGES=true
fi

mkdir -p .github/workflows

# Check activation.yml
if [[ -f ".github/workflows/activation.yml" ]]; then
  read -r -p "activation.yml already exists. Overwrite with a default one? [y/N] " answer
  case "$answer" in
    [Yy]* )
      echo "Downloading GitHub workflow for activation"
      curl -s https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/activation.yml > .github/workflows/activation.yml
      echo "Overwrote activation.yml."
      ;;
    * )
      echo "Skipping activation.yml overwrite."
      ;;
  esac
else
  echo "Downloading GitHub workflow for activation"
  curl -s https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/activation.yml > .github/workflows/activation.yml
  echo "Created a new activation.yml."
fi

# Check build-deploy.yml
if [[ -f ".github/workflows/build-deploy.yml" ]]; then
  read -r -p "build-deploy.yml already exists. Overwrite with a default one? [y/N] " answer
  case "$answer" in
    [Yy]* )
      echo "Downloading GitHub workflow for deploy"
      curl -s https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/build-deploy.yml > .github/workflows/build-deploy.yml
      echo "Overwrote build-deploy.yml."
      ;;
    * )
      echo "Skipping build-deploy.yml overwrite."
      ;;
  esac
else
  echo "Downloading GitHub workflow for deploy"
  curl -s https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/build-deploy.yml > .github/workflows/build-deploy.yml
  echo "Created a new build-deploy.yml."
fi

if [[ $(git status --porcelain .github/workflows) ]]; then 
  git add .github/workflows
  echo "Committing workflows to repo"
  git commit -m "Setting up unity project with CI" 1>/dev/null
  DID_MAKE_CHANGES=true
fi

# Keep asking until we get at least one valid platform
while true; do
  echo ""
  echo "Which platforms do you want to build? (space-separated choices)"
  echo "1) StandaloneOSX"
  echo "2) StandaloneWindows64"
  echo "3) StandaloneLinux64"
  echo "4) WebGL"
  echo ""
  echo "For example, '1 4' for Mac + WebGL, or '1 2 3 4' for all."

  read -p "Enter choice(s): " choices

  PLATFORM_LINES=""
  for choice in $choices; do
    case "$choice" in
      1)
        if [ -z "$PLATFORM_LINES" ]; then
          PLATFORM_LINES="        - StandaloneOSX"
        else
          PLATFORM_LINES="$PLATFORM_LINES
        - StandaloneOSX"
        fi
        ;;
      2)
        if [ -z "$PLATFORM_LINES" ]; then
          PLATFORM_LINES="        - StandaloneWindows64"
        else
          PLATFORM_LINES="$PLATFORM_LINES
        - StandaloneWindows64"
        fi
        ;;
      3)
        if [ -z "$PLATFORM_LINES" ]; then
          PLATFORM_LINES="        - StandaloneLinux64"
        else
          PLATFORM_LINES="$PLATFORM_LINES
        - StandaloneLinux64"
        fi
        ;;
      4)
        if [ -z "$PLATFORM_LINES" ]; then
          PLATFORM_LINES="        - WebGL"
        else
          PLATFORM_LINES="$PLATFORM_LINES
        - WebGL"
        fi
        ;;
      *)
        echo "Unknown choice: $choice (ignored)";;
    esac
  done

  if [[ -z "$PLATFORM_LINES" ]]; then
    echo "No valid platforms selected. Please try again."
  else
    echo ""
    echo "Selected platforms:"
    echo "$PLATFORM_LINES"
    echo ""
    break
  fi
done



update_build_deploy_platforms

# Now, if build-deploy.yml changed, commit it
if [[ $(git status --porcelain .github/workflows/build-deploy.yml) ]]; then
  git add .github/workflows/build-deploy.yml
  echo "Committing updated build-deploy.yml with new target platforms"
  git commit -m "Update build-deploy.yml with user-selected platforms"
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

if [[ "$REPO_VISIBILITY" = "private" || "$REPO_LOCATION" = "personal" ]]; then
  echo "Because this repo is not a public repo in roo-makes, you'll need to set its secrets."
  echo "This setup requires the following secrets:"
  echo "AWS_ACCESS_KEY_ID"
  echo "AWS_SECRET_ACCESS_KEY"
  echo "CLOUDFRONT_DISTRIBUTION_ID"
  echo "CLOUDFRONT_URL"
  echo "DISCORD_WEBHOOK"
  echo "S3_BUCKET"
  echo "S3_BUCKET_REGION"
  echo "UNITY_EMAIL"
  echo "UNITY_LICENSE"
  echo "UNITY_PASSWORD"
  echo "You can set them individually with \"gh secret set [SECRET NAME] [SECRET VALUE]\""
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
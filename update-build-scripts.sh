git stash

mkdir -p .github/workflows
curl https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/activation.yml > .github/workflows/activation.yml
curl https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/build-deploy.yml > .github/workflows/build-deploy.yml
git add .github/workflows
git commit -m "Updating CI scripts"

git stash apply


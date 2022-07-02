curl https://raw.githubusercontent.com/github/gitignore/main/Unity.gitignore > ./.gitignore
curl https://gist.githubusercontent.com/webbertakken/ff250a0d5e59a8aae961c2e509c07fbc/raw/b767c9c8762a2cf4823de43d3ec649379d8ad064/.gitattributes > ./.gitattributes
mkdir -p .github/workflows
curl https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/activation.yml > .github/workflows/activation.yml
curl https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/workflows/build-deploy.yml > .github/workflows/build-deploy.yml

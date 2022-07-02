curl https://raw.githubusercontent.com/github/gitignore/main/Unity.gitignore > ./.gitignore
git lfs install
curl https://gist.githubusercontent.com/webbertakken/ff250a0d5e59a8aae961c2e509c07fbc/raw/b767c9c8762a2cf4823de43d3ec649379d8ad064/.gitattributes > ./.gitattributes
mkdir -p .github/workflows
curl https://gist.githubusercontent.com/met5678/a340297383ceec2d2733a5406d3d06b6/raw/b1c16b958772df9e71966067e0d2d789a5d9743c/build-deploy.yml > .github/workflows/build-deploy.yml

gh secret set AWS_ACCESS_KEY_ID
gh secret set AWS_SECRET_ACCESS_KEY
gh secret set CLOUDFRONT_DISTRIBUTION_ID
gh secret set S3_BUCKET

# Unity/Github/S3 Deployment setup

This repo contains scripts meant to assist in setting up a new Unity project for automatic building and deployment to S3.

## Initial Setup (per-machine)

You only need to run this on your computer once. Ensure you have `git`, `git-lfs`, and `gh` installed. On a Mac, that means running:

```
brew update
brew install git git-lfs gh
```

## Repo Setup

You'll want to run this right after creating your Unity project (or anytime before committing it to Github).

```
curl setup-unity-project-for-ci.sh | bash
```

This script does the following for you:

1. Adds a [Unity-specific `.gitignore`](https://github.com/github/gitignore/blob/main/Unity.gitignore) to your project.
2. Sets up `git-lfs` and adds a general-purpose [`.gitattributes`](https://gist.github.com/webbertakken/ff250a0d5e59a8aae961c2e509c07fbc) to your project.
3. Adds two workflows to `.github/workflows`

- Unity License Activation
- Build/Deploy

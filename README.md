# Unity/Github/S3 Deployment setup

This repo contains scripts meant to assist in setting up a new Unity project for automatic building and deployment to S3. You do NOT need to clone this repo onto your computer, it's just here for reference and to allow my scripts to work.

## Initial Setup (per-machine)

You only need do this on your computer once, and then you can forget it for the most part. You'll be installing the following tools

- `git`: Basic command-line tool that handles version-control
- `brew`: Mac package manager, we'll just be using it to install the following tools.
- `git-lfs`: An extension to `git` that handles large non-text files (images, sounds, etc.). Very common for Unity projects.
- `gh`: The commmand-line tool for Github. It basically just duplicates all the functionality of the github website, but allows me to easily do that via scripts I've written to keep things simpler.

Follow the instructions below to install these tools. You'll enter all of these commands in the Mac `Terminal` app.

### Confirming that you have `git` installed

To check if git is installed, simply enter:

```
git
```

If it's not installed, you should be prompted to install it. Follow the prompts, and if it asks to install developer tools, let it.

### Installing `brew`

To check if you have `brew` installed, run this command:

```
which brew
```

If it outputs a file path, you're good, continue to the next section.

If it says `brew not found`, install `brew` by copying this into your terminal:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This will take a little while. Once it's done, you can continue.

### Installing `git-lfs` and `gh`

In your terminal, run the following commands:

```
brew install git-lfs
```

This may take awhile. Once it's done, run:

```
git lfs install
```

### Installing and setting up `gh`

To install the `gh` tool (Github's CLI), run the following command:

```
brew install gh
```

Once it's done, run:

```
gh auth login
```

Follow the prompts. When prompted to select between `https` and `ssh`, select `ssh`.

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

```

```

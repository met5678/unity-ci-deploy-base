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

If it shows nothing, or says `brew not found`, install `brew` by copying this into your terminal:

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

Follow the prompts. Recommended choices:

- `github.com` (not `github enterprise`)
- `ssh` (not `https`)
- Generate SSH key for me, no passphrase (it's just easier to deal with)
- Login with browser

## Repo Setup

You'll want to run this right after creating your Unity project (or anytime before committing it to Github).

```

curl https://raw.githubusercontent.com/roo-makes/unity-ci-deploy-base/main/setup-unity-project.sh | bash

```

This script does the following for you:

1. Initializes a git repo if there isn't already one there.
2. Adds a [Unity-specific `.gitignore`](https://github.com/github/gitignore/blob/main/Unity.gitignore) to your project.
3. Adds a general-purpose [`.gitattributes`](https://gist.github.com/webbertakken/ff250a0d5e59a8aae961c2e509c07fbc) to your project.
4. Adds two Github action workflows to `.github/workflows`, including the important `build-deploy` workflow.
5. Checks if this repo has been pushed to `Github` yet. If not, it prompts you asking where you want to put the repo. For now, answer (`1` for both options).

### Changing or Disabling Discord notifications

By default, the `build-deploy` action will update Discord if it finds a `DISCORD_WEBHOOK` secret. If you are in an org with this already set (such as `roo-makes`), you don't have to do anything.

If you'd like to disable the Discord notifications, add a `DISCORD_WEBHOOK` secret to your repo and set it to `disabled`.

## Dev Notes

### Setup script pseudocode

```
create_repo
  Part of roo-makes org?
    true
      Public?
        true
          gh repo create --public
        false
          gh repo create --private
    false
      gh repo create

set_secrets
  prompt for AWS_ACCESS_KEY_ID
  prompt for AWS_SECRET_ACCESS_KEY
  prompt for S3_BUCKET (default unity-ci-test-builds)
  prompt for DISCORD_WEBHOOK

Test if in git repo
  true
    cd into root
    test if contains Unity folders
      true
        continue
      false
        print error, exit
  false
    test if contains Unity folders
      true
        git init
        create_repo
      false
        print error, exit


if not in roo_makes, or if private
  set_secrets

Copy .gitignore via curl
Copy .gitattributes via curl
Copy workflows via curl
```

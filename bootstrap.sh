#!/bin/zsh

set -e

echo "Welcome to the AuditBoard Bootstrapper!"
echo
echo "This script will install Homebrew, Git, and the GitHub CLI."
echo "It will also authenticate you with GitHub and clone the AuditBoard dev environment."
echo
echo "Press any key to get started..."
read

### Install Homebrew
# This also installs the Xcode Command Line Tools
if ! command -v brew &> /dev/null; then
    echo "First we will installing Homebrew."
    echo "Press any key to continue..."
    read

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Homebrew instructs users to run these commands, let's just do it for them
    echo >> $HOME/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    echo "Homebrew installed!"
else
    echo "Homebrew already installed"
fi

echo
echo "Next we will install Git and the GitHub CLI."
echo
echo "Press any key to continue..."
read

brew install git
brew install gh

if gh auth status -h github.com > /dev/null; then
    echo "GitHub CLI already authenticated"
else
    echo "Now we will authenticate with GitHub"
    echo "Please sign in when prompted. Make sure to authorize the 'AuditBoard' GitHub account if requested."
    echo
    echo "Press any key to continue..."
    read
    gh auth login -h github.com -p https -w
fi

# This may not be necessary 
gh auth setup-git

echo
echo "Finally we will clone the AuditBoard dev environment."
echo
echo "Press any key to continue..."
read

if [ ! -d ~/.auditboard ]; then
    # This is a trick to output to both stdout and a file descriptor for inspection
    exec 5>&1
    # Use gh repo clone to get better error messages
    res=$(gh repo clone soxhub/auditboard-dev-env ~/.auditboard -- --branch=v2 --depth=1 |& tee /dev/fd/5)
    if [[ $res == *"Authorize in your web browser"* ]]; then
        echo "You are not currently authorized to access the AuditBoard (soxhub) GitHub Account."
        echo "Please ensure that IT has given you access and then open the above link in your browser."
        echo "Once you have authorized the account, re-run this script."
        exit 1
    fi
    if [ ! -d ~/.auditboard/.git ]; then
        echo "Failed to clone the AuditBoard dev environment."
        echo "Please check the error message above and try again."
        exit 1
    fi
else
    echo "AuditBoard dev environment already cloned"
fi

if ! grep -q "AB_DEV_HOME" "$HOME/.zshenv"; then
    echo "export AB_DEV_HOME=~/.auditboard" >> ~/.zshenv
fi

if ! grep -q "\$AB_DEV_HOME/global/bin" "$HOME/.zshenv"; then
    echo "export PATH=\$PATH:\$AB_DEV_HOME/global/bin" >> ~/.zshenv
fi

echo "Bootstrapping done. Please open a new terminal and run \`ab-setup-dev\` to finish setup."

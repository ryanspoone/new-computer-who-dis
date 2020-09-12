#!/bin/bash
# Setup fresh MacOS system

# Show Library folder
chflags nohidden ~/Library
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles YES
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Install xcode
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install Node.js
brew install node
brew pin node
brew install yarn

# Install base apps
# See https://formulae.brew.sh/formula/
brew cask install visual-studio-code
brew cask install google-chrome
brew cask install firefox
brew cask install authy
brew cask install dashlane
brew cask install iterm2
brew cask install slack
brew cask install sketch
brew cask install postman
brew cask install flux
brew cask install shellcheck

# Add Fira Code font
brew tap homebrew/cask-fonts
brew cask install font-fira-code

# Generate SSH keys
if [[ ! -f ~/.ssh/id_rsa ]]; then
    ssh-keygen -t rsa -b 4096 -C "me@ryanspoone.com"
    ssh-add ~/.ssh/id_rsa
fi

# Setup git defaults
git config --global user.name "Ryan Spoone"
git config --global user.email "me@ryanspoone.com"

# Setup node manager
# Make cache folder (if missing) and take ownership
sudo mkdir -p /usr/local/n
sudo chown -R "$(whoami)" /usr/local/n
# Take ownership of node install destination folders
sudo chown -R "$(whoami)" /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share

# Make folder for development
mkdir -p ~/dev
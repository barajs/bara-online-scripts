#!/bin/bash

# Automated set up a new linux Ubuntu machine
# 1. Install CURL (if not yet existed)
# 2. Command: curl -sSL https://scripts.barajs.dev/linux/new-machine.sh | bash

setup() {
  # Prepare the machine
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-add-repository universe
  sudo apt-get update

  # Install dependencies
  sudo apt-get install -y git zsh tmux nmon nload htop

  # Install core softwares
  ## ZSH
  echo "Installing OH-MY-ZSH..."
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  
  echo "Installing OH-MY-ZSH basic plugins..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
  sed -i 's/\(git\)/git zsh-syntax-highlighting zsh-autosuggestions docker/' ~/.zshrc && \
  source ~/.zshrc
}

main() {
  setup
}

main

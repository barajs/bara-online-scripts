#!/bin/bash

# Automated set up a new linux Ubuntu machine
# 1. Install CURL (if not yet existed)
# 2. Command: curl -sSL https://scripts.barajs.dev/linux/new-centos.sh | bash

setup() {
  # Prepare the machine
  yum -y install yum-plugin-priorities
  sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo
  yum -y install epel-release
  sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo
  sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo
  yum -y install centos-release-scl-rh centos-release-scl
  yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
  yum -y update

  # Install dependencies
  yum install -y git zsh tmux nmon nload htop

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

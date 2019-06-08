#!/bin/bash

# Automated set up a new linux Centos machine
# 1. Install CURL (if not yet existed)
# 2. Command: curl -sSL https://scripts.barajs.dev/linux/new-centos.sh | bash

setup() {
  # Prepare the machine
  sudo yum -y install epel-release yum-plugin-priorities \
  https://download.ceph.com/rpm-luminous/el7/noarch/ceph-release-1-1.el7.noarch.rpm
  sed -i -e "s/enabled=1/enabled=1\npriority=1/g" /etc/yum.repos.d/ceph.repo
  sudo yum -y update

  # Install dependencies
  sudo yum install -y git zsh tmux nmon nload htop python-setuptools python2 python-pkg-resources

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

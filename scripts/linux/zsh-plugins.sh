# BARA PERMANENT SCRIPTS
# 
# A script to setup Oh-My-ZSH Plugin
#
# One line install command:
# Syntax: curl https://scripts.barajs.dev | bash -s
#

#! /bin/bash

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
sed -i 's/\(git\)/git zsh-syntax-highlighting zsh-autosuggestions docker/' ~/.zshrc && \
source ~/.zshrc

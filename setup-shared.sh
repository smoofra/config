#!/bin/bash


ln -sf ~/config/bin ~
ln -sf ~/config/mac-bashrc ~/.bashrc
ln -sf ~/config/init.el ~/.emacs
ln -sf ~/config/gitconfig ~/.gitconfig
ln -sf ~/config/tmux ~/.tmux.conf
ln -sf ~/config/quiltrc  ~/.quiltrc

mkdir -p ~/.ipython/profile_default/
ln -sf ~/config/dot-ipython/profile_default/static ~/.ipython/profile_default/static

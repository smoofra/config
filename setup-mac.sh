#!/bin/bash

set -e

. ~/config/setup-shared.sh

#prevent  iTunes from launching every time  you plug in a phone
defaults write com.apple.iTunes ignore-devices 1
defaults write com.apple.iTunesHelper ignore-devices 1

defaults write com.apple.finder AppleShowAllFiles TRUE
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

( cd ~/config ; git config user.email larry@elder-gods.org )

if ! [[ -e ~/config/private ]]; then
    git clone git@github.com:smoofra/config-private.git private
fi

if ! [[ -e ~/bin.local ]]; then
    mkdir ~/bin.local
fi

if ! [[ -e ~/.oh-my-zsh ]]; then 
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
fi
ln -sf ~/config/dot-zshrc ~/.zshrc
ln -sf ~/config/dot-zshenv ~/.zshenv


if ! [[ -e ~/.ssh ]]; then
    mkdir ~/.ssh
    chmod 0700 ~/.ssh
fi

if ! grep -q config/private/ssh ~/.ssh/config 2>/dev/null; then
    echo -e "\n\nInclude ~/config/private/ssh" >> ~/.ssh/config
fi

#UGH
if ! [[ -e ~/Library/Developer/Xcode/UserData/KeyBindings ]]; then
    mkdir -p  ~/Library/Developer/Xcode/UserData/KeyBindings
fi
if !    [[ -e ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings ]] ; then
    cp ~/config/Default.idekeybindings ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings
    echo "KEYBINDS ->"
fi

ln -sf ~/config/dot-lldbinit ~/.lldbinit

if [[ -e ~/.jupyter ]]; then
    rm ~/.jupyter
fi
ln -sf ~/config/dot-jupyter ~/.jupyter

if ! [[ -e ~/.docker ]]; then
    mkdir ~/.docker
fi
ln -sf ~/config/docker-config.json ~/.docker/config.json

if ! [[ -e ~/Library/KeyBindings ]]; then
    mkdir -p ~/Library/KeyBindings
fi
cp ~/config/KeyBindings/* ~/Library/KeyBindings


for code in Code "Code - Insiders"; do
    if ! [[ -e ~/Library/"Application Support"/"$code"/User ]]; then
        mkdir -p ~/Library/"Application Support"/"$code"/User
    fi
    ln -sf ~/config/vscode/keybindings.json ~/Library/"Application Support"/"$code"/User/
    mkdir -p ~/Library/"Application Support"/"$code"/User/snippets/
    ln -sf ~/config/vscode/snippets.code-snippets ~/Library/"Application Support"/"$code"/User/snippets/
    ln -sf ~/config/vscode/settings.json ~/Library/"Application Support"/"$code"/User/
done


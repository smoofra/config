#!/bin/bash

. ~/config/setup-shared.sh

defaults write com.apple.finder AppleShowAllFiles TRUE
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

echo ". ~/.bashrc" >~/.bash_profile

( cd ~/config ; git config user.email larry@elder-gods.org )

if ! [[ -e ~/apple_config ]]; then
    git clone ssh://git@stash.sd.apple.com/~lawrence_danna/apple_config.git ~/apple_config
fi

if ! [[ -e ~/bin.local ]]; then
    mkdir ~/bin.local
fi

if ! [[ -e ~/corekernelutils ]]; then
    git clone ssh://git@stash.sd.apple.com/coreosint/corekernelutils.git ~/corekernelutils
fi
ln -sf ~/corekernelutils/make_xnu.py ~/bin.local/make_xnu

if ! [[ -e ~/flamegraph ]]; then
    git clone git@github.com:brendangregg/FlameGraph.git ~/flamegraph
fi
ln -sf ~/flamegraph/flamegraph.pl ~/bin.local/flamegraph

if ! [[ -e ~/.ssh ]]; then
    mkdir ~/.ssh
    chmod 0700 ~/.ssh
fi

~/config/replacements.py

cat ~/config/ssh <(~/apple_config/ssh.py)  >~/.ssh/config


test -e ~/Library/LaunchAgents || mkdir -p ~/Library/LaunchAgents

ln -sf ~/config/com.andersbakken.rtags.agent.plist  ~/Library/LaunchAgents/com.andersbakken.rtags.agent.plist
launchctl load ~/Library/LaunchAgents/com.andersbakken.rtags.agent.plist >/dev/null 2>&1

ln -sf ~/config/org.elder-gods.ipython.plist ~/Library/LaunchAgents/org.elder-gods.ipython.plist
launchctl load ~/Library/LaunchAgents/org.elder-gods.ipython.plist >/dev/null 2>&1


#UGH
if ! [[ -e ~/Library/Developer/Xcode/UserData/KeyBindings ]]; then
    mkdir -p  ~/Library/Developer/Xcode/UserData/KeyBindings
fi
if !    [[ -e ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings ]] || \
        [[ ~/config/Default.idekeybindings -nt  ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings ]]; then
    cp ~/config/Default.idekeybindings ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings
else
    cp ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings ~/config/Default.idekeybindings
fi


ln -sf ~/config/dot-lldbinit ~/.lldbinit

if [[ -e ~/.jupyter ]]; then
    rm ~/.jupyter
fi
ln -sf ~/config/dot-jupyter ~/.jupyter

if ! [[ -e ~/Library/KeyBindings ]]; then
    mkdir -p ~/Library/KeyBindings
fi
cp ~/config/KeyBindings/* ~/Library/KeyBindings

. ~/apple_config/setup.sh


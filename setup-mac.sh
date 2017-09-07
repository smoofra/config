#!/bin/bash

. ~/config/setup-shared.sh

defaults write com.apple.finder AppleShowAllFiles TRUE
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES

echo ". ~/.bashrc" >~/.bash_profile

( cd ~/config ; git config user.email larry@elder-gods.org )

if ! [[ -e ~/.Brewfile ]]; then
    ln -s ~/config/Brewfile ~/.Brewfile
fi

if ! [[ -e /data/homebrew ]]; then
	cd /data && mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
fi

export PATH=/data/homebrew/bin:"$PATH"

if ! which gls >/dev/null; then
    brew bundle install --global
fi

if ! [[ -e ~/apple_config ]]; then
    git clone ssh://git@stash.sd.apple.com/~lawrence_danna/apple_config.git ~/apple_config
    git -C ~/apple_config remote set-url --add --push origin ssh://git@stash.sd.apple.com/~lawrence_danna/apple_config.git
    git -C ~/apple_config remote set-url --add --push origin ssh://odin/data/Backup/apple_config.git
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
if !    [[ -e ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings ]] ; then
    cp ~/config/Default.idekeybindings ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings
    echo "KEYBINDS ->"
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

if ! [[ -e ~/.atom ]]; then
	ln -s ~/config/dot-atom ~/.atom
fi

if ! [[ -e /Applications/Emacs.app ]]; then
	url=$(wget -q  -O- https://emacsformacosx.com/atom/release | perl -lne 'print $1 if /<link.*href="(.*)"/' | head -1)
	wget -O /tmp/$(basename $url) $url
	hdiutil attach /tmp/$(basename $url)
	cp -a /Volumes/Emacs/Emacs.app /Applications/
	hdiutil  detach /Volumes/Emacs
	ln -sf $(find /Applications/Emacs.app/ -name emacsclient | grep x86_64 | sort | tail -1) ~/bin.local/
fi

. ~/apple_config/setup.sh

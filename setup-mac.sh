
. ~/config/setup-shared.sh

defaults write com.apple.finder AppleShowAllFiles TRUE

echo ". ~/.bashrc" >~/.bash_profile

( cd ~/config ; git config user.email larry@elder-gods.org )

if ! [[ -e ~/apple_config ]]; then
    git clone ssh://git@stash.sd.apple.com/~lawrence_danna/apple_config.git ~/apple_config
fi

if ! [[ -e ~/tools ]]; then
    git clone ssh://git@stash.sd.apple.com/~lawrence_danna/tools.git ~/tools
fi
ln -sf ~/tools/* ~/bin.local

if ! [[ -e ~/flamegraph ]]; then
    git clone git@github.com:brendangregg/FlameGraph.git ~/flamegraph
fi
ln -sf ~/flamegraph/flamegraph.pl ~/bin.local/flamegraph

if ! [[ -e ~/.ssh ]]; then
    mkdir ~/.ssh
    chmod 0700 ~/.ssh
fi

~/config/replacements.py

cat ~/config/ssh ~/apple_config/ssh  >~/.ssh/config

ln -sf ~/config/com.andersbakken.rtags.agent.plist  ~/Library/LaunchAgents/com.andersbakken.rtags.agent.plist
launchctl load ~/Library/LaunchAgents/com.andersbakken.rtags.agent.plist >/dev/null 2>&1

. ~/apple_config/setup.sh


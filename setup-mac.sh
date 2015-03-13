
ln -sf ~/config/bin ~
ln -sf ~/config/mac-bashrc ~/.bashrc
ln -sf ~/config/init.el ~/.emacs
ln -sf ~/config/gitconfig ~/.gitconfig
ln -sf ~/config/quiltrc  ~/.quiltrc

echo ". ~/.bashrc" >~/.bash_profile

( cd ~/config ; git config user.email larry@elder-gods.org )

if ! [[ -e ~/apple_config ]]; then
    git clone ssh://git@stash.sd.apple.com/~lawrence_danna/apple_config.git ~/apple_config
fi


if ! [[ -e ~/.ssh ]]; then
    mkdir ~/.ssh
    chmod 0700 ~/.ssh
fi

~/config/replacements.py

cat ~/config/ssh ~/apple_config/ssh  >~/.ssh/config

. ~/apple_config/setup.sh


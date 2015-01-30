
ln -sf ~/config/bin ~
ln -sf ~/config/mac-bashrc ~/.bashrc
ln -sf ~/config/dot-emacs ~/.emacs
ln -sf ~/config/gitconfig ~/.gitconfig

echo ". ~/.bashrc" >~/.bash_profile

( cd ~/config ; git config user.email larry@elder-gods.org )








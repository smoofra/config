#  -*- mode: shell-script -*-



if test -z "$OPS1"; then
    OPS1="$PS1"
fi

function longps1() {
    PS1=$(perl -e '$_ = shift; s/^/\\n/; s/\\\$(\s*)$/\\n\\\$$1/; print' "$OPS1")
}

function shortps1() {
    PS1="$OPS1"
}

export EDITOR=myedit
export PATH=$($HOME/bin/addpath $HOME/bin.local $HOME/bin $HOME/usr/bin "$PATH")
export MANPATH=$(addpath ~/usr/share/man)

alias rerc='. ~/config/bashrc'
alias sr='. ~/.transient-environment'
alias ls='ls --color=auto'
alias bsg='mplayer -idx -softvol -softvol-max 1000'

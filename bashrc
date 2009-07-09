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
export PATH=$(~/bin/addpath ~/bin.local ~/bin ~/usr/bin ~/usr/libexec/git-core /usr/lib/git-core "$PATH")
export MANPATH=$(addpath ~/usr/share/man $(env MANPATH= manpath))
export PYTHONPATH=$(addpath ~/usr/lib/python "$PYTHONPATH")

alias rerc='. ~/config/bashrc'
alias sr='. ~/.transient-environment'
alias ls='ls --color=auto'
alias bsg='mplayer -idx -softvol -softvol-max 1000'

function gmane() { 
    /usr/bin/slrn -h news.gmane.org "$@"
}

function slrn() { 
    /usr/bin/slrn -h news.eternal-september.org "$@"
    bak checknews
}



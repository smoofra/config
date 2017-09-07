# -*- mode: shell-script -*-

[[ -e ~/bin/addpath ]] && PATH=$(~/bin/addpath "$HOME/bin.local" "$HOME/bin" "$HOME/apple_config/bin" /homebrew/bin /usr/local/bin /usr/local/sbin /src/sysperf/bin "$PATH" )

export PERL5LIB
[[ -e ~/bin/addpath ]] && PERL5LIB=$(~/bin/addpath ~/perl5/lib/perl5 "$PERL5LIB" )

if which gls >/dev/null ; then
	alias ls='gls --color=auto'
elif ls --version 2>/dev/null | grep -iq gnu ; then
	alias ls='ls --color=auto'
fi

if which grm >/dev/null ; then
	alias rm=grm
fi

if which gfind >/dev/null ; then
    alias find=gfind
fi

if which gxargs >/dev/null ; then
    alias xargs=gxargs
fi

export EDITOR=vim

if [[ ! -z "$INSIDE_EMACS" ]] ; then
    export TERM=vt100
    export EDITOR=emacsclient
    alias  python='env PAGER="el -r" python'
fi

# NOTE: install coreutils to get pwd to display the tilde
function trim_pwd() {
    local pwd
    local len
    local expr
    local limit
    limit=45

    expr=expr
    if [ ! x$($expr length "FOO" 2>/dev/null) = "x3" ]; then
        expr=gexpr
        if [ ! x$($expr length "FOO" 2>/dev/null) = "x3" ]; then
            pwd
            return
        fi
    fi

    pwd="$(pwd)"
    len=$($expr length "$pwd")


    if [ "$($expr substr "$pwd" 1 $($expr length "$HOME"))" = "$HOME" ]; then
        pwd="~$($expr substr "$pwd" $($expr 1 + $($expr length "$HOME")) $len)"
        len=$($expr length "$pwd")
    fi

    if [ $len -gt $limit ]; then
        pwd=..."$($expr substr "$pwd" $($expr $len - $limit) $len)"
    fi
    echo "$pwd"
}

function userathost() {
	if [[ `whoami` = lawrence_danna ]]; then
		hostname
	else
		echo `whoami`@`hostname`
	fi
}

#export PS1='\u@\h:\w\$ '
export PS1='$(userathost):$(trim_pwd)\$ '

if echo "$PATH" | tr : \\n | grep -q ~/x-tools ; then
    export PS1="-XT- $PS1"
fi

alias rerc='. ~/.bashrc'

PERL_MB_OPT="--install_base \"/Users/lawrence_danna/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/lawrence_danna/perl5"; export PERL_MM_OPT;


export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export HOMEBREW_TEMP=/tmp

# wifi on, wifi off
alias wifi='networksetup -setairportpower airport'

# mouse on / mouse off
alias mouse='tmux set -g mode'

function resetup() {
    if [ `uname -s` = Darwin ]; then
        bash ~/config/setup-mac.sh
    else
        bash ~/config/setup-shared.sh
    fi
}

function import-keys() {
	 cp ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings ~/config/Default.idekeybindings
	 echo "KEYBINDS <--"
}

function backup() {
    echo "safari bookmarks -> odin"
    ~/config/bin/bookmarks --safari | ssh odin 'cat > /data/Backup/safari-bookmarks.plist'  && echo " ok"

    echo "safari bookmarks -> owncloud"
    ~/config/bin/bookmarks --safari --owncloud --upload  && echo " ok"

    echo "instapaper bookmarks -> owncloud"
    ~/config/bin/bookmarks --instapaper --owncloud --upload  && echo " ok"
}

alias bear='bear -a'

alias rerdm='launchctl unload  ~/Library/LaunchAgents/com.andersbakken.rtags.agent.plist ; launchctl load  ~/Library/LaunchAgents/com.andersbakken.rtags.agent.plist'

alias lsd='gls -l -r --sort=time --color=auto'

alias apm='/Applications/Atom.app//Contents/Resources/app/apm/bin/apm'

if  [ -e ~/apple_config/bashrc ]; then
    . ~/apple_config/bashrc
fi

function ipy {
    if ! tmux list-sessions 2>/dev/null | grep -q '^ipython:' ; then
        tmux new-session -d  -s ipython 'ipython notebook --no-browser'
        sleep 5
    fi
    open -a iPython
}

function wrap {
    case $1 in
        on)
            tput smam
            ;;
        off)
            tput rmam
            ;;
        *)
            echo "huh?"
            ;;
    esac
}


export PROMPT_COMMAND=""

if type update_terminal_cwd 2>/dev/null | grep -q 'shell function'; then
    PROMPT_COMMAND+="update_terminal_cwd; "
fi

# Avoid duplicates
export HISTCONTROL=ignoredups:erasedups

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# After each command, append to the history file and reread it
PROMPT_COMMAND+="history -a; history -c; history -r; "

# eternal history
export HISTFILESIZE=
export HISTSIZE=
export HISTFILE=~/.bash_history

if [ -e ~/.bashrc-private ]; then
    . ~/.bashrc-private
fi

function ptr() {
    pbpaste | tr ' ' \\n | el
}

function path() {
    if [ $# = 0 ]; then
        echo "$PATH" | tr : \\n
    elif [ $# = 1 ]; then
        local dir
        dir="$(~/bin/relpath "$1")"
        export DT_NO_RESPAWN=1
        export DYLD_LIBRARY_PATH=$(~/bin/addpath "$dir" "$DYLD_LIBRARY_PATH")
        export DYLD_FRAMEWORK_PATH=$(~/bin/addpath "$dir" "$DYLD_FRAMEWORK_PATH")
        export PATH=$(~/bin/addpath "$dir" "$PATH")
    else
        echo ?
        return 1
    fi
}

function fwhich() {
    which "$@" | xargs -d\\n follow
}

#export PYSPARK_PYTHON=python3
export SPARK_LOCAL_IP=127.0.0.1

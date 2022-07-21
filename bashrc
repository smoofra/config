# -*- mode: shell-script -*-

unset MAILCHECK

for dir in /homebrew/bin /Volumes/data/homebrew/bin /opt/brew/bin ; do 
  if [[ -e $dir ]] ; then
    [[ -e ~/bin/addpath ]] && PATH=$(~/bin/addpath $dir "$PATH")
    export HOMEBREW_TEMP=$(dirname $dir)/tmp
  fi
done

[[ -e ~/bin/addpath ]] && PATH=$(~/bin/addpath \
    "$HOME/bin.local" \
    "$HOME/bin" \
    "$HOME/apple_config/bin" \
    "$HOME/Library/Python/3.9/bin" \
    "$HOME/Library/Python/3.8/bin" \
    /usr/local/bin \
    /usr/local/sbin \
    "$PATH" )

PATH=$(echo $PATH | tr : \\n | grep -v 'VMware Fusion' | tr \\n :)

#export LC_ALL="en_US.UTF-8"

export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export PERL5LIB
[[ -e ~/bin/addpath ]] && PERL5LIB=$(~/bin/addpath ~/perl5/lib/perl5 "$PERL5LIB" )

if which gls >/dev/null ; then
	alias ls='gls --color=auto'
    alias lsd='gls -l -r --sort=time --color=auto'
elif ls --version 2>/dev/null | grep -iq gnu ; then
	alias ls='ls --color=auto'
    alias lsd='ls -l -r --sort=time --color=auto'
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

function export-keys() {
	cp ~/config/Default.idekeybindings ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings 
	echo "KEYBINDS -->"
}


function import-keys() {
	 cp ~/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings ~/config/Default.idekeybindings
	 echo "KEYBINDS <--"
}

function backup-bookmarks() {
    echo "safari bookmarks -> odin"
    ~/config/bin/bookmarks --safari | ssh odin 'cat > /data/Backup/safari-bookmarks.plist'  && echo " ok"

    echo "safari bookmarks -> owncloud"
    ~/config/bin/bookmarks --safari --owncloud --upload  && echo " ok"

    echo "instapaper bookmarks -> owncloud"
    ~/config/bin/bookmarks --instapaper --owncloud --upload  && echo " ok"
}

function backup-photos() {
    rsync -rul --progress /data/Photos\ Library.photoslibrary odin:/data/Pictures
}

alias bear='bear -a'

alias rerdm='launchctl unload  ~/Library/LaunchAgents/com.andersbakken.rtags.agent.plist ; launchctl load  ~/Library/LaunchAgents/com.andersbakken.rtags.agent.plist'


alias apm='/Applications/Atom.app//Contents/Resources/app/apm/bin/apm'


alias dl='sudo -u www-data youtube-dl -x --audio-format mp3 -o "%(title)s.%(ext)s"'

alias occ='sudo -u www-data php /data/owncloud/occ'

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

function histprompt() {
	history -a
	history -c
	history -r
}

# After each command, append to the history file and reread it
PROMPT_COMMAND+="histprompt"

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
    elif [ $# = 2 ] && [ $1 = "-d" ]; then
        DYLD_LIBRARY_PATH=$(~/bin/delpath "$2" "$DYLD_LIBRARY_PATH")
        DYLD_FRAMEWORK_PATH=$(~/bin/delpath "$2" "$DYLD_FRAMEWORK_PATH")
        PATH=$(~/bin/delpath "$2" "$PATH")
    elif [ $# = 1 ]; then
        local dir
        dir="$(~/bin/relpath "$1")"
        export DT_NO_RESPAWN=1
        export DYLD_LIBRARY_PATH=$(~/bin/addpath "$dir" "$DYLD_LIBRARY_PATH")
        export DYLD_FRAMEWORK_PATH=$(~/bin/addpath "$dir" "$DYLD_FRAMEWORK_PATH")
        export PATH=$(~/bin/addpath "$dir" "$PATH")
    else
        echo '?'
        return 1
    fi
}

function xcpath() {
    path $(xcode-select -p)/../Frameworks
    path $(xcode-select -p)/../SharedFrameworks
}

function fwhich() {
    which "$@" | xargs -d\\n follow
}

function fix-rtags() {
    old_rpath=$(otool -l /data/homebrew/Cellar/rtags/*/bin/rc  | perl -lne 'print $1 if m:([^\s]*Xcode.app[^\s]+):')
    new_rpath=$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/lib
    echo old: $old_rpath
    echo new: $new_rpath
    if [ $old_rpath != $new_rpath ]; then
        echo fixing
        install_name_tool -rpath $old_rpath $new_rpath /data/homebrew/Cellar/rtags/*/bin/rc
        install_name_tool -rpath $old_rpath $new_rpath /data/homebrew/Cellar/rtags/*/bin/rp
        install_name_tool -rpath $old_rpath $new_rpath /data/homebrew/Cellar/rtags/*/bin/rdm
    fi
}

# function pywhich() {
#     python -c "import $1; print $1.__file__" | perl -pe 's/\.py[co]$/\.py/'
# }


#export PYSPARK_PYTHON=python3
export SPARK_LOCAL_IP=127.0.0.1

if [ `uname -s` = Darwin ]; then
    export GOPATH=/Volumes/data/go
elif [ `uname -s` = Linux ]; then
    export GOPATH=$HOME/src/go
fi

function docker-screen() {
    screen  ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty
}

function mksha() {
    shasum $1 | awk '{print $1}' > $1.sha
}

if [ `uname -n` = odin ]; then
	export CCACHE_MAXSIZE=100G
	export CCACHE_DIR=$HOME/build/ccache
fi

function rm-python-links() {
    for x in /usr/local/bin/*;  do
        if readlink "$x" | grep -q 'Python\.framework'; then
            echo + rm "$x"
            rm "$x"
        fi
    done
}

function link-python() {
    # for x in /usr/local/bin/*;  do
    #     if readlink "$x" | grep -q Python.framework; then
    #         rm "$x"
    #     fi
    # done
   ln -sf /AppleInternal/Library/Frameworks/Python.framework/Versions/Current/bin/python3 /usr/local/bin/python3
}

function link-public-python() {
    # for x in /usr/local/bin/*;  do
    #     if readlink "$x" | grep -q Python.framework; then
    #         rm "$x"
    #     fi
    # done
   ln -sf /Library/Frameworks/Python.framework/Versions/3.8/bin/python3 /usr/local/bin/python3
}

function dockertags() {
    curl https://registry.hub.docker.com/v1/repositories/$1/tags | jq -r  ' .[] | .name'
}

alias pip3='python3 -m pip'
alias virtualenv='python3 -m virtualenv'

export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home

function scan-build() {
    `xcrun -sdk macosx.internal -f clang | xargs dirname | xargs dirname`/local/bin/scan-build "$@"
}

if [ -e ~/.cargo/env ]; then
    . ~/.cargo/env
fi

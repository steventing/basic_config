# Title:        bashrc file
# Author:       darkgerm

# ==================== Historical setting ===================={{{1

# TODO: need to clean up.

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
#HISTCONTROL=ignoredups:erasedups
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

#export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
#export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=5000
HISTFILESIZE=5000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# ==================== Settings ===================={{{1
shopt -s globstar
shopt -s checkjobs

# tcsh compatible
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
bind 'C-x:insert-comment'

# completion
if [ -f /usr/local/share/bash-completion/bash_completion.sh ]; then
    source /usr/local/share/bash-completion/bash_completion.sh

    # do not compelet rsync. rsync is a little bit weird 0.o
    complete -o default rsync

else
    # simple completion
    complete -cf sudo
    complete -cf man
    complete -cf which
fi

if [ -f ~/.git-prompt.sh ]; then
    source ~/.git-completion.bash
    source ~/.git-prompt.sh
else
    alias __git_ps1=':'
fi

# dkg completion
_dkg() {
    COMPREPLY=( $( compgen -W 'allow regist help sync keysync' -- "$2" ) )
}
complete -F _dkg dkg

# FreeBSD service completion
_service () {
    local cur
    cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $( compgen -W '$( service -l )' -- $cur ) )
    return 0
}
complete -F _service service


# ==================== aliases ===================={{{1
# ability
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias vim='vim -p'
alias ls='ls -GF'
alias rsync='rsync -avP'   # --del is too dangerous  -z compress
alias ipcat='ypcat hosts | sort -t. -n -k1,1 -k2,2 -k3,3 -k4,4'
alias pg='ps aux | grep'
alias lg='lsmod | grep'
alias wget='wget --no-check-certificate'

# short cut
alias l='ls -CF'
alias ll='ls -al'
alias la='ls -a'
alias lt='ls -altr'   # sort by time
alias py='python3'
alias py2='python2'
alias v='vim'
#alias m='man'
alias g='grep'
alias bs2='ssh bbsu@ssh.bs2.to'
alias ptt='ssh bbsu@ptt.cc'
alias tmux='tmux -2'
alias sr='screen -rd'
alias lock='gnome-screensaver-command -l && xset dpms force off'
sc() { STY=$1 screen -S $1 ; }
alias mk='make clean && make -j8'

# cds
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'


# ==================== environment ===================={{{1
export PAGER='less'
export EDITOR='vim'

export LESS="-fmrS"
export LESSCHARDEF="8bcccbcc18b95.."

# For colorful man pages
export LESS_TERMCAP_mb='[1;32m'
export LESS_TERMCAP_md='[1;32m'
export LESS_TERMCAP_me='[0m'
export LESS_TERMCAP_se='[0m'
export LESS_TERMCAP_so='[1;44;36m'
export LESS_TERMCAP_ue='[0m'
export LESS_TERMCAP_us='[1;33m'

export LSCOLORS="gxfxcxdxbxegedabagacad"
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
export CLICOLOR=1
export CLICOLOR_FORCE=1
export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
#export TERM=screen-256color-bce
#export PYTHONSTARTUP=~/.pyrc.py

if [ -e /usr/share/terminfo/x/xterm-256color ]; then
export TERM='xterm-256color'
else
export TERM='xterm-color'
fi

if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi


# ==================== PROMPT ===================={{{1

__errno() {
    local errno=$?
    if [ $errno -eq 0 ]; then
        echo -e "\e[1;32m"0
    else
        echo -e "\e[1;31m"$errno
    fi
}

set_prompt () {
    local E='\e[m'
    local D='\e[0;30m'; local LD='\e[1;30m'   # Dark
    local R='\e[0;31m'; local LR='\e[1;31m'   # Red
    local G='\e[0;32m'; local LG='\e[1;32m'   # Green
    local Y='\e[0;33m'; local LY='\e[1;33m'   # Yellow
    local B='\e[0;34m'; local LB='\e[1;34m'   # Blue
    local M='\e[0;35m'; local LM='\e[1;35m'   # Magenta
    local C='\e[0;36m'; local LC='\e[1;36m'   # Cyan
    local W='\e[0;37m'; local LW='\e[1;37m'   # White
    # on the line your cursor is, the color should be surrounded by \[ \].

    if [ "$(whoami)" == "root" ]; then
        local NAME_COLOR=$LR
    else
        local NAME_COLOR=$LY
    fi

    if [ "$1" == "2" ]; then
        PS1=''
        PS1+='┌─'$LC'[\T]'              # date time
        PS1+=$LW"-<$NAME_COLOR\u"       # user
        PS1+=$LW'@\h>-'                 # @host
        PS1+='$(__errno)'               # errno
        PS1+=$LM'$(__git_ps1)'          # git
        PS1+=$LM' [\#]'                 # count
        PS1+=$E'\n'                     # newline
        PS1+='└─'\\[$LG\\]'[\w]'        # path
        PS1+=\\[$LM\\]' >'\\[$E\\]
    else
        PS1=''
        PS1+=\\[$LC\\]'\A'              # time
        PS1+=\\[$NAME_COLOR\\]'\u'      # user
        PS1+=\\[$E\\]'@'\\[$LW\\]'\h'   # @host
        PS1+=\\[$LG\\]'[\w]'            # path
        PS1+=\\[$LR\\]'$?'              # errno
        PS1+=\\[$LM\\]' >'\\[$E\\]
    fi
}

set_prompt 2     # default is 2 line prompt


# ==================== functions ===================={{{1
untar() {
    if [ -f $1 ] ; then
        case $1 in
        *.tar.bz2)  echo "tar jxvf $1"; tar jxvf $1 ;;
        *.tar.gz)   echo "tar zxvf $1"; tar zxvf $1 ;;
        *.tar)      echo "tar xvf $1";  tar xvf $1  ;;
        *.tbz2)     echo "tar xvif $1"; tar xvjf $1 ;;
        *.tgz)      echo "tar xvzf $1"; tar xvzf $1 ;;
        *.txz)      echo "tar xvJf $1"; tar xvJf $1 ;;
        *.bz2)      echo "bunzip2 $1";  bunzip2  $1 ;;
        *.rar)      echo "unrar x $1";  unrar x $1  ;;
        *.gz)       echo "gunzip $1";   gunzip $1   ;;
        *.zip)      echo "unzip $1";    unzip $1    ;;
        *.7z)       echo "7z x $1";     7z x $1     ;;
        *)          echo "don't know how to extract '$1' Q_Q" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

findtext() {
    local op='-l'
    if [ "$1" == "-t" ]; then   # print intext instead of filename
        local op=''
        shift
    fi

    find . -exec grep --color=always $op $1 {} \;
}


# use vim's :TOhtml command to convert
# $@ is the arglist
# vim -e  EX mode
# vim -n  no swap file
# known bugs: output file can't contain spaces.
tohtml() {
    if [ "$1" == "" ]; then
        echo 'usage: tohtml input [output]'

    elif [ "$2" == "" ]; then
        vim -ne +TOhtml +wq! +qall! -- "$1" > /dev/null
    else
        vim -ne +TOhtml +"wq! $2" +qall! -- "$1" > /dev/null
    fi
}



# ==================== System Dependant ===================={{{1
_freeBSD_setup() {
    export PATH='~/bin'
    export PATH+=':/usr/local/bin:/usr/local/sbin'
    export PATH+=':/usr/bin:/usr/sbin'
    export PATH+=':/bin:/sbin'
    alias pkgsearch='pkg search -Q comment'
    pkgversion() { [ -z "$1" ] && pkg version -v || pkg version -v -x $1 ; }
}

_darwin_setup() {
    export PATH='~/bin'
    export PATH+=':/usr/local/sbin:/usr/local/bin'
    export PATH+=':/sbin:/bin'
    export PATH+=':/usr/sbin:/usr/bin'
    #export PATH+=':/usr/local/share/python'
    #export PYTHONPATH="/usr/local/lib/python2.7/site-packages"

    vpy_enable() {
        echo 'Restore /Library/Frameworks/Python.framework ...'
        sudo mv \
            /Library/Frameworks/Python.framework.bak \
            /Library/Frameworks/Python.framework
    }
    vpy_disable() {
        echo 'Backup /Library/Frameworks/Python.framework ...'
        sudo mv \
            /Library/Frameworks/Python.framework \
            /Library/Frameworks/Python.framework.bak
    }
    vpy() {
        if [ ! -f /Library/Frameworks/Python.framework/Versions/2.7/bin/python ]; then
            echo 'Use vpy_enable first.'
            return 1
        fi
        echo
        echo ' *** This is /Library/Frameworks/Python.framework/Versions/2.7/bin/python ***'
        echo
        /Library/Frameworks/Python.framework/Versions/2.7/bin/python "$@"
    }
}

_linux_setup() {
    alias ls='ls -GF --color=always'

    export PATH='~/bin:'$PATH
}

_cygwin_setup() {
    alias mosh="mosh --server='mosh-server new -l LANG=en_US.UTF-8'"
    alias ls='ls -GF --color=always'
    alias ifconfig='ipconfig | iconv -f big5'
    alias open='cygstart'
    alias setup='/setup/setup-x86 --site http://mirror.cs.nctu.edu.tw/cygwin/ --quiet-mode --package-manager --no-shortcuts'

    # use the system python
    alias python=_cygwin_python
    export PYTHONSTARTUP="C:\cygwin\home\darkgerm\dkgconf\local\pyrc.py"

    export PATH='~/bin:/bin:/usr/bin:'$PATH

    cd /cygdrive/d
}

# $# is arg num
# Syntax    Effective result
#   $*      $1 $2 $3 ... ${N}
#   $@      $1 $2 $3 ... ${N}
#  "$*"     "$1c$2c$3c...c${N}"
#  "$@"     "$1" "$2" "$3" ... "${N}"
_cygwin_python() {
    pyarg='-u'
    if [ $# -eq 0 ]; then
        pyarg='-ui'
    fi
    /cygdrive/c/Python27/python $pyarg "$@"
}

case "$(uname -s)" in
    FreeBSD)    _freeBSD_setup ;;
    Darwin)     _darwin_setup  ;;
    Linux)      _linux_setup   ;;
    CYGWIN_NT*) _cygwin_setup  ;;
    *)
        echo 'WARNING: unknown operating system: '$(uname -s)
        ;;
esac

# }}}

if [ -f ~/.bashlocal ]; then
    echo 'exec .bashlocal ...'
    . ~/.bashlocal
fi
#cursor color
echo -ne "\e]12;red\a"
stty -ixon
#export PATH='/home/steven/FOSSAPC/arm-2010q1/bin':$PATH
#export PATH="$PATH":/var/opt/steven/depot_tools
#export PATH="/usr/lib/ccache:$PATH"
#export C9_DIR="$HOME"/.c9
#export PATH="$C9_DIR/node/bin:$C9_DIR/node_modules/.bin:$PATH"
export PIP_RESPECT_VIRTUALENV=true
export TERM=xterm-256color

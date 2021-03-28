# .bashrc
# Unlike earlier versions, Bash4 sources your bashrc on non-interactive shells.
# The line below prevents anything in this file from creating output that will
# break utilities that use ssh as a pipe, including git and mercurial.
[ -z "$PS1" ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

if [ -f /usr/facebook/ops/rc/master.bashrc ]; then
    source /usr/facebook/ops/rc/master.bashrc
fi

PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH

export EDITOR=emacs

if [ -f $LOCAL_ADMIN_SCRIPTS/scm-prompt ]; then
    source $LOCAL_ADMIN_SCRIPTS/scm-prompt
fi

function parse_hg_branch {
    if command -v _dotfiles_scm_info; then
	if [[ -n $(_dotfiles_scm_info) ]]; then
            # wrap in parens
            echo "$(_dotfiles_scm_info)"
	fi
    fi
}

# Show current hg bookmark
function hgproml {
    # here are a bunch of colors in case
    # you want to get colorful
    local        BLUE="\[\033[0;34m\]"
    local         RED="\[\033[0;31m\]"
    local   LIGHT_RED="\[\033[1;31m\]"
    local       GREEN="\[\033[0;32m\]"
    local LIGHT_GREEN="\[\033[1;32m\]"
    local       WHITE="\[\033[1;37m\]"
    local  LIGHT_GRAY="\[\033[0;37m\]"
    local RESET_COLOR="\[\033[0m\]"

      export PS1="\
$LIGHT_GREEN[\u:\w$LIGHT_RED:\$(parse_hg_branch)$LIGHT_GREEN]\
\$$RESET_COLOR "
      PS2='> '
      PS4='+ '
}
hgproml

# PS1="[\e[1;92m\u \e[1;94m\$PWD\e[m]\$ "

HISTSIZE=1000000
HISTFILESIZE=-1
HISTCONTROL=ignoredups
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
shopt -s checkwinsize
shopt -s histappend

alias grep='grep --color=always'
alias less='less -R'
alias fbgs="fbgs -s --color=on -f '\.py$'"

# If not on my local machine, attach to session named "auto" (starting if it doesn't exist)
if [[ ! $(hostname) = *domdefelice* && ! $TMUX && -t 0 && $TERM_PROGRAM != vscode ]]; then
    tmux $TMUX_OPTIONS new-session -As auto
fi

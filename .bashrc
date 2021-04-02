# .bashrc: executed by bash(1) for non-login shells.
# See /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples.

# Unlike earlier versions, Bash4 sources your bashrc on non-interactive shells.
# The line below prevents anything in this file from creating output that will
# break utilities that use ssh as a pipe, including git and mercurial.
# Test whether the prompt variable $PS1 is set and if it isn't (which is the
# case for non-interactive shells) exit the script.
[ -z "$PS1" ] && return

# Source global definitions.
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

if [ -f /usr/facebook/ops/rc/master.bashrc ]; then
    source /usr/facebook/ops/rc/master.bashrc
fi

if [ -f $LOCAL_ADMIN_SCRIPTS/scm-prompt ]; then
    source $LOCAL_ADMIN_SCRIPTS/scm-prompt
fi

# Make less more friendly for non-text input files, see lesspipe(1).
if command -v lesspipe > /dev/null 2>&1; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Set PATH so it includes user's private bin if it exists.
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH
export EDITOR=emacs

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1).
HISTSIZE=1000000
HISTFILESIZE=-1

# Don't put duplicate lines in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups

# Update history after each command.
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Append to the history file, don't overwrite it.
shopt -s histappend

# Alias definitions.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable programmable completion features.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi


function parse_hg_branch {
    if command -v _dotfiles_scm_info > /dev/null 2>&1; then
	if [[ -n $(_dotfiles_scm_info) ]]; then
            # wrap in parens
            echo "$(_dotfiles_scm_info)"
	fi
    fi
}

# Show current hg bookmark
function hgproml {
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

# If on my personal laptop, launch tmux.
if [[ $(hostname) = *pop-os* && ! $TMUX && -t 0 && $TERM_PROGRAM != vscode ]]; then
    tmux $TMUX_OPTIONS
fi

# If not on my local machine, attach to session named "auto" (starting it if it doesn't exist)
if [[ ! $(hostname) = *domdefelice* && ! $TMUX && -t 0 && $TERM_PROGRAM != vscode ]]; then
    tmux $TMUX_OPTIONS new-session -As auto
fi

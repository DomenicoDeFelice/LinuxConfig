# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/go/bin" ] ; then
    PATH="$HOME/go/bin:$PATH"
fi

export PATH
export EDITOR="emacs"

# Session picker on tty1
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    LIGHT_GREEN="\033[1;32m"
    LIGHT_GRAY="\033[0;37m"
    RESET_COLOR="\033[0m"

    echo
    echo -e "${LIGHT_GRAY}1)${LIGHT_GREEN} Shell (default)"
    echo -e "${LIGHT_GRAY}2)${LIGHT_GREEN} Sway"
    echo -e "${LIGHT_GRAY}3)${LIGHT_GREEN} Xfce"
    echo -e "${LIGHT_GRAY}4)${LIGHT_GREEN} KDE Plasma"
    echo -e "${RESET_COLOR}"
    read -p "Session [1]: " choice
    echo

    case $choice in
        2) exec sway ;;
        3) exec startxfce4 ;;
        4) exec startplasma-wayland ;;
        *) ;;
    esac
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

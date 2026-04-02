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

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

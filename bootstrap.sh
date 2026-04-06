#!/bin/bash
set -e

install_packages() {
    local one_by_one=false
    if [ "$1" = "--one-by-one" ]; then
        one_by_one=true
        shift
    fi
    local file="$1"
    shift
    if [ -s "$file" ]; then
        echo -e "\033[1;34m* Installing packages from $file...\033[0m"
        if $one_by_one; then
            xargs -n1 "$@" < "$file"
        else
            xargs "$@" < "$file"
        fi
    else
        echo -e "\033[1;33m* No packages to install from $file\033[0m"
    fi
}

install_packages packages.apt sudo apt install -y
install_packages --one-by-one packages.go go install
install_packages packages.cargo cargo install
install_packages packages.rustup rustup component add
install_packages --one-by-one packages.uv uv tool install
install_packages packages.npm.global sudo npm install -g

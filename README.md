# Dotfiles

Configuration files for my Linux setup, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Usage

```bash
cd ~/dotfiles

# Install everything
stow -t ~ */

# Install specific packages
stow -t ~ bash emacs

# Remove a package
stow -t ~ -D tmux
```

Each top-level directory is a stow package.

## Packages

Package lists are stored in `packages.*` files. To install everything:

```bash
./bootstrap.sh
```

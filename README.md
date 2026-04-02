# Dotfiles

Configuration files for my Linux setup, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Usage

```bash
cd ~/dotfiles
stow -t ~ home
```

This creates symlinks in `~` pointing to the files in `home/`.

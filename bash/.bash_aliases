# .bash_aliases: alias definitions.

alias ls='ls --color=always'
alias grep='grep --color=always'
alias less='less -R'
alias fbgs="fbgs -s --color=on -f '\.py$'"
alias emacsall="hg d -r.^ --stat | awk '{ print \$1 }' | sed 's/fbcode\///' | head -n -1 | xargs emacsclient -nw -a ''"

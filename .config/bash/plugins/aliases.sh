# LS.
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --color --group-directories-first"
    alias ll="eza -lbh"
    alias lS="ll -ssize"
    alias lT="ll -snewest"
else
    if [[ "$OSTYPE" == darwin* ]]; then
        alias ls="ls -G"
    else
        alias ls="ls -g --color=auto"
    fi
    alias ll="ls -lh"
    alias lS="ll -S"
    alias lT="ll -T"
fi
alias l="ll"
alias la="ll -a"
alias ldot="ll -d .*"

# Mask built-ins with better defaults.
alias mkdir="mkdir -p"
alias rm="rm -I"

# Grep
alias grep="grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}"

# Date
alias timestamp="date '+%Y-%m-%d %H:%M:%S'"
alias datestamp="date '+%Y-%m-%d'"

# Git
if command -v lazygit >/dev/null 2>&1; then
    alias lg="lazygit"
fi

# Bare repositories.
alias dotfiles='GIT_WORK_TREE=~ GIT_DIR=~/.dotfiles PATH=~/.opt/dotfiles/bin:$PATH'

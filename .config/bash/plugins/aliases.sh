# Mask built-ins with better defaults.
alias mkdir="mkdir -p"
alias rm="rm -I"
if [[ "$OSTYPE" == darwin* ]]; then
    alias ls="ls -G"
else
    alias ls="ls --group-directories-first --color=auto"
fi

# Grep
GREP_EXCL=(.bzr CVS .git .hg .svn .idea .tox)
alias grep="grep --color=auto --exclude-dir={\${(j:,:)GREP_EXCL}}"

# Ls
alias ll='ls -lh'
alias la='ls -lAh'
alias ldot='ls -ld .*'

# Date
alias timestamp="date '+%Y-%m-%d %H:%M:%S'"
alias datestamp="date '+%Y-%m-%d'"

# Find
alias fd='find . -type d -name'
alias ff='find . -type f -name'

# Bare repositories.
alias dotfiles='GIT_WORK_TREE=~ GIT_DIR=~/.dotfiles PATH=~/.local/dotfiles/bin:$PATH'
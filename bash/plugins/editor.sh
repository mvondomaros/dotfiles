if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
    alias vim='nvim'
    alias vi='nvim'
elif command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
    alias vi='vim'
fi

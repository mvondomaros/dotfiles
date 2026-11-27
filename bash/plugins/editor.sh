if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
else
    export EDITOR=vi
fi
export VISUAL="$EDITOR"
alias v='"$EDITOR"'
# vi and vim open the best available editor; `command vim` reaches Vim itself.
if command -v nvim >/dev/null 2>&1; then
    alias vi='nvim' vim='nvim'
elif command -v vim >/dev/null 2>&1; then
    alias vi='vim'
fi

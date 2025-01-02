#!/bin/zsh

if command -v nvim >/dev/null 2>&1; then
    alias vi=nvim
    alias vim=nvim
    alias vimdiff="nvim -d"
    export EDITOR="nvim"
    export MANPAGER="nvim +Man!"
    export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
    alias vi=vim
    export EDITOR="vim"
    export VISUAL="vim"
fi
if command -v fleet >/dev/null 2>&1; then
    export VISUAL=fleet
fi

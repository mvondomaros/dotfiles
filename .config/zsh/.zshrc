#!/bin/zsh

# Antidote
[[ -d $ZDOTDIR/.antidote ]] || git clone --depth 1 https://github.com/mattmc3/antidote $ZDOTDIR/.antidote
source $ZDOTDIR/.antidote/antidote.zsh
antidote load $ZDOTDIR/.zplugins

#
## Set the locale.
#export LANG=en_US.UTF-8
#export LC_CTYPE=$LANG
#
## Set the editor.
#if command -v nvim >/dev/null 2 >&1; then
#    alias vi=nvim
#    alias vim=nvim
#    alias vimdiff="nvim -d"
#    export EDITOR="nvim"
#    export MANPAGER="nvim +Man!"
#    export VISUAL="nvim"
#elif command -v vim >/dev/null 2 >&1; then
#    alias vi=vim
#    export EDITOR="vim"
#    export VISUAL="vim"
#fi
#if command -v fleet >/dev/null 2 >&1; then
#    export VISUAL=fleet
#fi
#
## Configure history-substring-search.
#HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
#bindkey '^[[A' history-substring-search-up
#bindkey '^[[B' history-substring-search-down

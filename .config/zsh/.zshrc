#!/bin/zsh

# Antidote
[[ -d $ZDOTDIR/.antidote ]] || git clone --depth 1 https://github.com/mattmc3/antidote $ZDOTDIR/.antidote
source $ZDOTDIR/.antidote/antidote.zsh
antidote load $ZDOTDIR/.zplugins

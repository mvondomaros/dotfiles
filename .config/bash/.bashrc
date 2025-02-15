#!/usr/bin/env bash

# Use XDG base dirs.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

# Support alternative BASH_HOME locations.
BASH_HOME="$XDG_CONFIG_HOME"/bash
BASH_DATA_HOME="$XDG_DATA_HOME"/bash
BASH_CACHE_HOME="$XDG_CACHE_HOME"/bash
REPO_HOME="$BASH_CACHE_HOME"/repos
mkdir -p "$BASH_HOME" "$BASH_DATA_HOME" "$BASH_CACHE_HOME" "$REPO_HOME"

# Use vi mode
set -o vi

plugins=(
    options
    repos
    preexec
    colors
    starship
    prompt
    history
    editor
    fzf
    atuin
    conda
    completions
    aliases
    atuin
)

for _plugin in "${plugins[@]}"; do
    if [ -r "$BASH_HOME/plugins/${_plugin}.sh" ]; then
        source "$BASH_HOME/plugins/${_plugin}.sh"
    else
        echo >&2 "Plugin not found: '$_plugin'."
    fi
done

unset _plugin

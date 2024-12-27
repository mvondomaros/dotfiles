#!/bin/zsh

# Set ZDOTDIR.
export ZDOTDIR=${ZDOTDIR:-$HOME/.config/zsh}

# Set XDG_*.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

# Declare path arrays.
typeset -gU cdpath fpath mailpath path

# Set up the path.
path=(
    $HOME/bin(/N)
    $HOME/.local/bin(/N)
    /opt/homebrew/{,s}bin(/N)
    $path
)

# Disable shell sessions.
export SHELL_SESSIONS_DISABLE=1

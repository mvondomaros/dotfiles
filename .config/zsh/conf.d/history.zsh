#!/bin/zsh

# Set up the HISTFILE.
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

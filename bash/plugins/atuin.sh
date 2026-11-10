if command -v atuin >/dev/null 2>&1; then
    source "$XDG_CONFIG_HOME/bash/plugins/bash-preexec.sh"
    eval "$(atuin init bash)"
fi

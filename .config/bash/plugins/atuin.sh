# Enable atuin bash integration.
if type atuin >/dev/null 2>&1; then
    eval "$(atuin init bash)"
fi

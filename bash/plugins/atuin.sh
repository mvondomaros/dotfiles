# Enable atuin bash integration.
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init bash)"
fi

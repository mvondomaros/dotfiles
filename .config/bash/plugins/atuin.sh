# Enable atuin bash integration.
[[ -d ~/.opt/atuin ]] && export PATH=~/.opt/atuin:$PATH
if type atuin >/dev/null 2>&1; then
    eval "$(atuin init bash)"
fi

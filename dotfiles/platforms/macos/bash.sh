# Bash remains usable on macOS; Kitty uses Fish for interactive terminals.
export BROWSER="${BROWSER:-open}"

# Apple's setuid top ignores user terminfo locations, including ~/.terminfo.
top() {
    if [ "${TERM:-}" = xterm-kitty ]; then
        TERM=xterm-256color command top "$@"
    else
        command top "$@"
    fi
}

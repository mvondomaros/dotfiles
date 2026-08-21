# Package installation must be an explicit action, never a shell-startup side
# effect. This helper is primarily intended for Linux hosts without Homebrew.
bootstrap_cli_tools() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "curl is required to bootstrap CLI tools." >&2
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "jq is required by gah; install it with the system package manager." >&2
        return 1
    fi

    if ! command -v gah >/dev/null 2>&1; then
        echo "Bootstrapping gah..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/get-gah/gah/refs/heads/master/tools/install.sh)" || return
    fi

    gah install atuinsh/atuin
    gah install BurntSushi/ripgrep
    gah install eza-community/eza
    gah install neovim/neovim
    gah install sharkdp/fd
    gah install junegunn/fzf
    gah install starship/starship
}

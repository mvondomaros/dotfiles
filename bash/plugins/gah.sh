install_jq() {
    echo "Bootstrapping jq..."
    jq_url="https://github.com/stedolan/jq/releases/download/jq-1.8.1/jq-linux-amd64"
    curl -L "$jq_url" -o "$HOME/.local/bin/jq"
    chmod +x "$HOME/.local/bin/jq"
}

install_gah() {
    echo "Bootstrapping gah..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/get-gah/gah/refs/heads/master/tools/install.sh)"
}

if ! command -v jq >/dev/null 2>&1; then
    install_jq
fi

if ! command -v gah >/dev/null 2>&1; then
    install_gah
    gah install atuinsh/atuin
    gah install BurntSushi/ripgrep
    gah install eza-community/eza
    gah install neovim/neovim
    gah install sharkdp/fd
    gah install junegunn/fzf
    gah install starship/starship
fi


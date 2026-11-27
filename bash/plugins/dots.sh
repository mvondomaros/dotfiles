# Completions for dots, the single entry point of this checkout.
_dots_complete() {
    local targets='tools editor agents vscode packages appstore os all'
    local tools='pixi lazygit rg fd atuin btop eza nvim starship ruff ty rsync shfmt shellcheck stylua tinymist typst tree-sitter websocat codex claude bash-language-server fish-lsp'
    local words
    if [ "$COMP_CWORD" -eq 1 ]; then
        words='update outdated install link status role host targets adopt help'
    else
        case ${COMP_WORDS[1]} in
            update) words="$targets $tools --backup --no-pull" ;;
            outdated) words="$targets $tools" ;;
            install) words="$targets $tools --backup" ;;
            link) words='--backup' ;;
            targets) words="$targets default" ;;
            role) words='workstation server' ;;
            host) words="default $(cd "$DOTFILES_HOME/hosts" 2>/dev/null && printf '%s ' *)" ;;
            adopt) words="$tools all --check" ;;
        esac
    fi
    # The words contain no spaces or globs; bash 3.2 on macOS lacks mapfile.
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "$words" -- "${COMP_WORDS[COMP_CWORD]}"))
}
complete -F _dots_complete dots

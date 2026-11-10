# Shared Bash defaults. Keep this file free of output, writes, and activation.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
DOTFILES_HOME="$XDG_CONFIG_HOME/dotfiles"
case $(uname -s) in Darwin) DOTFILES_PLATFORM=macos ;; *) DOTFILES_PLATFORM=linux ;; esac
if [ -z "${DOTFILES_HOST:-}" ] && [ -r "$DOTFILES_HOME/local/host" ]; then
    IFS= read -r DOTFILES_HOST < "$DOTFILES_HOME/local/host" || :
fi
DOTFILES_HOST=${DOTFILES_HOST:-default}
case $DOTFILES_HOST in *[!a-zA-Z0-9_-]*|'') DOTFILES_HOST=default ;; esac
export DOTFILES_PLATFORM DOTFILES_HOST

# Prefer existing system/site tools. Local binaries fill in missing tools.
for _dir in "$HOME/.local/bin" "$HOME/.pixi/bin" "$HOME/.opt/atuin"; do
    if [ -d "$_dir" ]; then
        case :$PATH: in *:"$_dir":*) ;; *) PATH="$PATH:$_dir" ;; esac
    fi
done
export PATH
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
export FZF_DEFAULT_OPTS_FILE="${FZF_DEFAULT_OPTS_FILE:-$XDG_CONFIG_HOME/fzf/config}"
export PAGER="${PAGER:-less}"
for _config in     "$DOTFILES_HOME/platforms/$DOTFILES_PLATFORM/env.sh"     "$DOTFILES_HOME/hosts/$DOTFILES_HOST/env.sh"     "$DOTFILES_HOME/local/env.sh"
do
    [ ! -r "$_config" ] || source "$_config"
done
unset _dir _config

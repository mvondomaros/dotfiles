set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache
set -g DOTFILES_HOME $XDG_CONFIG_HOME/dotfiles
set -gx DOTFILES_PLATFORM linux
if test (uname -s) = Darwin
    set -gx DOTFILES_PLATFORM macos
end
if not set -q DOTFILES_HOST; and test -r $DOTFILES_HOME/local/host
    read -l selected_host <$DOTFILES_HOME/local/host
    set -gx DOTFILES_HOST $selected_host
end
set -q DOTFILES_HOST; or set -gx DOTFILES_HOST default
if not string match -qr '^[a-zA-Z0-9_-]+$' -- "$DOTFILES_HOST"
    set -gx DOTFILES_HOST default
end
set -gx GIT_CONFIG_GLOBAL $XDG_CONFIG_HOME/git/config
set -gx EZA_CONFIG_DIR $XDG_CONFIG_HOME/eza
set -q FZF_DEFAULT_OPTS_FILE; or set -gx FZF_DEFAULT_OPTS_FILE $XDG_CONFIG_HOME/fzf/config
set -q PAGER; or set -gx PAGER less
for dir in $HOME/.local/bin $HOME/.pixi/bin $HOME/.opt/atuin
    if test -d $dir
        fish_add_path --global --append --path $dir
    end
end
for config in $DOTFILES_HOME/platforms/$DOTFILES_PLATFORM/env.fish $DOTFILES_HOME/hosts/$DOTFILES_HOST/env.fish $DOTFILES_HOME/local/env.fish
    if test -r $config
        source $config
    end
end

# Set XDG directories.
set -q XDG_CONFIG_HOME; or set -Ux XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME; or set -Ux XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME; or set -Ux XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME; or set -Ux XDG_CACHE_HOME $HOME/.cache

# Set GIT_CONFIG
set -q GIT_CONFIG; or set -Ux GIT_CONFIG $HOME/.config/git/.gitconfig

# Set paths.
fish_add_path ~/.local/bin
fish_add_path ~/.config/tools

# Set XDG directories.
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state
set -gx XDG_CACHE_HOME $HOME/.cache

# Set GIT_CONFIG
set -gx GIT_CONFIG $HOME/.config/git/.gitconfig

# Set paths.
fish_add_path ~/.local/bin
fish_add_path ~/.config/tools

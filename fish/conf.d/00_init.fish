# Set XDG defaults without overriding values supplied by the environment.
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache

# Set GIT_CONFIG
set -gx GIT_CONFIG_GLOBAL $XDG_CONFIG_HOME/git/config

# Set paths.
fish_add_path ~/.local/bin
fish_add_path $XDG_CONFIG_HOME/tools

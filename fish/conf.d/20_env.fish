# Locale settings
set -gx LANG en_US.UTF-8
set -gx LC_COLLATE C

# Eza config
set -gx EZA_CONFIG_DIR $XDG_CONFIG_HOME/eza

# Pager & browser, editor
set -gx PAGER less
set -gx BROWSER open
set -Ux EDITOR vim

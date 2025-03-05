# Set language and collate order.
set -q LANG; or set -Ux LANG en_US.UTF-8
set -q LC_COLLATE; or set -Ux LC_COLLATE C

# Set eza config dir.
set -q EZA_CONFIG_DIR; or set -Ux EZA_CONFIG_DIR $XDG_CONFIG_HOME/eza

if status is-interactive
    # Set pager and browser.
    set -q PAGER; or set -Ux PAGER less
    set -q BROWSER; or set -Ux BROWSER open
end

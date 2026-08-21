# Locale settings
set -gx LANG en_US.UTF-8
set -gx LC_COLLATE C

# Eza config
set -gx EZA_CONFIG_DIR $XDG_CONFIG_HOME/eza

# Pager and platform-appropriate browser, unless supplied by the environment.
set -q PAGER; or set -gx PAGER less

if not set -q BROWSER
    if test (uname) = Darwin; and type -q open
        set -gx BROWSER open
    else if type -q xdg-open
        set -gx BROWSER xdg-open
    end
end

if status is-interactive
    # Set theme.
    fish_config theme choose "Catppuccin Mocha"

    ## Set LS_COLORS.
    #if not set -q LS_COLORS
    #    if type -q vivid
    #        set -Ux LS_COLORS (vivid generate catppuccin-mocha)
    #    else
    #        set -Ux LS_COLORS (cat $XDG_CONFIG_HOME/lscolors/catppuccin-mocha)
    #    end
    #end
end

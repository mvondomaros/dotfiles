if status is-interactive
    if not set -q __theme_initialized
        set -U __theme_initialized 1
        fish_config theme choose "Catppuccin Latte"
    end
end

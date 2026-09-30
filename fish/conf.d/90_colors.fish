if status is-interactive
    if not set -q __ayu_light_theme_initialized
        set -U __ayu_light_theme_initialized 1
        fish_config theme choose ayu
    end
end

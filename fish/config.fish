if status is-interactive
    fish_vi_key_bindings
    for config in $DOTFILES_HOME/platforms/$DOTFILES_PLATFORM/config.fish $DOTFILES_HOME/hosts/$DOTFILES_HOST/config.fish $DOTFILES_HOME/local/config.fish
        if test -r $config
            source $config
        end
    end
    type -q starship; and starship init fish | source
    type -q atuin; and atuin init fish | source
    type -q fzf; and fzf --fish | source
end

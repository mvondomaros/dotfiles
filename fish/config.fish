if status is-interactive
    # Use vi keybindings.
    fish_vi_key_bindings

    # Set up starship.
    type -q starship; and starship init fish | source

    # Set up atuin.
    type -q atuin; and atuin init fish | source

    # Set up fzf.
    type -q fzf; and fzf --fish | source
end

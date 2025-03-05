if status is-interactive
    if type -q nvim
        set -q EDITOR; or set -Ux EDITOR nvim
        set -q MANPAGER; or set -Ux MANPAGER "nvim +Man!"
        alias vi nvim
        alias vim nvim
        alias vimdiff "nvim -d"
    else if type -q vim
        set -q EDITOR; or set -Ux EDITOR vim
        alias vi vim
    end
end

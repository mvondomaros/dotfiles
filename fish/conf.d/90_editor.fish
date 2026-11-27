if type -q nvim
    set -gx EDITOR nvim
else if type -q vim
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end
set -gx VISUAL $EDITOR
if status is-interactive
    alias v '$EDITOR'
    # vi and vim open the best available editor; `command vim` reaches Vim itself.
    if type -q nvim
        alias vi nvim
        alias vim nvim
    else if type -q vim
        alias vi vim
    end
end

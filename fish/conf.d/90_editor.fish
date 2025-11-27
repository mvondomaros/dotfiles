if type -q nvim
    set -gx EDITOR nvim
    alias vim nvim
    alias vi nvim
else if type -q vim
    set -gx EDITOR vim
    alias vi vim
end


if type -q fzf; and type -q fd
    function browse
        set -l path (
            fd . $HOME \
                --exclude Applications \
                --exclude Apps \
                --exclude Library \
                --exclude Movies \
                --exclude Music \
                --exclude Pictures \
                --exclude Downloads \
                --max-depth 15 \
            | fzf --height=40% --reverse \
                  --prompt='open> '
        )

        test -z "$path"; and return

        if test -d "$path"
            cd "$path"
        else
            $EDITOR "$path"
        end

        set -g fish_bind_mode insert
        commandline -f repaint
    end

    bind -M default ' ' browse
end

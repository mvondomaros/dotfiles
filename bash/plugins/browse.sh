if command -v fzf >/dev/null 2>&1 && command -v fd >/dev/null 2>&1; then
  browse() {
    local path

    path="$(
      fd . "$HOME" \
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
    )" || return

    [ -z "$path" ] && return

    if [ -d "$path" ]; then
      cd "$path" || return
    else
      "$EDITOR" "$path"
    fi
  }

  bind -m vi-command '"\e ": "browse\n\C-h"'
  bind -m vi-insert  '"\e ": "browse\n\C-h"'
fi


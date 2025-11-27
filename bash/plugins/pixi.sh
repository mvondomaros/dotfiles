if [[ -x "$HOME/.pixi/bin/pixi" ]]; then
    export PATH="$HOME/.pixi/bin:$PATH"

    pixi_version_file="$HOME/.config/pixi/version"
    pixi_completion_file="$HOME/.config/bash/completions/pixi.bash"
    pixi_current_version="$("$HOME/.pixi/bin/pixi" --version 2>/dev/null)"

    mkdir -p "$HOME/.config/pixi" "$HOME/.config/bash/completions"

    if [[ ! -f "$pixi_version_file" ]] \
       || [[ ! -f "$pixi_completion_file" ]] \
       || [[ "$(cat "$pixi_version_file")" != "$pixi_current_version" ]]; then

        "$HOME/.pixi/bin/pixi" completion --shell bash >| "$pixi_completion_file"
        echo "$pixi_current_version" >| "$pixi_version_file"
    fi

    [[ -r "$pixi_completion_file" ]] && source "$pixi_completion_file"
fi


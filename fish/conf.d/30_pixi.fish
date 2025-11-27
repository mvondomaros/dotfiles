if type -q pixi
    set -l version_file ~/.config/pixi/version
    set -l completion_file ~/.config/fish/completions/pixi.fish
    set -l current_version (pixi --version 2>/dev/null)

    if not test -e $version_file; or test (cat $version_file) != $current_version
        pixi completion --shell=fish > $completion_file
        echo $current_version > $version_file
    end
end

if type -q pixi
    set -l version_file $XDG_CONFIG_HOME/pixi/version
    set -l completion_file $XDG_CONFIG_HOME/fish/completions/pixi.fish
    set -l current_version (pixi --version 2>/dev/null)

    mkdir -p (dirname $version_file) (dirname $completion_file)

    if not test -e $version_file; or not test -e $completion_file; or test (cat $version_file) != $current_version
        pixi completion --shell=fish > $completion_file
        echo $current_version > $version_file
    end
end

if not set -q EDITOR
    if not type -q hx
        echo "Bootstrapping helix"
    end
    set -Ux EDITOR hx
end

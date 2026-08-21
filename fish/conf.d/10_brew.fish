if test (uname) = Darwin
    # Installation is intentionally handled outside shell startup.
    if type -q brew
        eval (brew shellenv)
    else
        for brew_prefix in /opt/homebrew /usr/local
            if test -x $brew_prefix/bin/brew
                eval ($brew_prefix/bin/brew shellenv)
                break
            end
        end
    end
end

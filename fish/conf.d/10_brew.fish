if test (uname) = Darwin
    set -l brew_prefix /opt/homebrew

    # Bootstrap.
    if not test -x $brew_prefix/bin/brew
        if status is-interactive
            echo "Bootstrapping Homebrew"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        end
    end

    # Initialize.
    if test -x $brew_prefix/bin/brew
        eval ($brew_prefix/bin/brew shellenv)
    end
end


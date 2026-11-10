for prefix in /opt/homebrew /usr/local
    if test -x $prefix/bin/brew
        # Explicit shell name also works when Fish was launched over SSH.
        eval ($prefix/bin/brew shellenv fish)
        break
    end
end
set -q BROWSER; or set -gx BROWSER open

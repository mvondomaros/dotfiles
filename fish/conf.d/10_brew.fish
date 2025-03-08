if set -q BREW_PREFIX
else if test -d /opt/homebrew
    set -Ux BREW_PREFIX /opt/homebrew
else if status is-interactive; and test (uname -s) = Darwin
    echo "Bootstrapping Homebrew"
    set -Ux BREW_PREFIX /opt/homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
end
$BREW_PREFIX/bin/brew shellenv | source

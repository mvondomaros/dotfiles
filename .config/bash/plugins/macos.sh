# Check requirements.
[[ "$OSTYPE" == darwin* ]] || return 1

# Change to the current Finder directory.
function cdf() {
    cd "$(pfd)" || return
}

# Hide hidden dotfiles in Finder.
function hidefiles() {
    defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder
}

# Show hidden dotfiles in Finder.
function showfiles() {
    defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
}

# Have Siri let me know when a process is complete.
function lmk() {
    # eg: sleep 2 && lmk
    say "${*:-Process complete}"
}

# Read man page with Preview.app
function manp() {
    if [[ $# -eq 0 ]]; then
        echo >&2 'manp: You must specify the manual page you want'
        return 1
    fi
    mandoc -T pdf "$(/usr/bin/man -w "$*")" | open -fa Preview
}

# Open the current directory in Finder
function ofd() {
    open "$PWD"
}

# Take a quick look at a file using an appropriate viewer
function peek() {
    [[ $# -gt 0 ]] && qlmanage -p "$*" &>/dev/null &
}

# Print the frontmost Finder directory.
function pfd() {
    osascript 2>/dev/null <<EOF
    tell application "Finder"
      return POSIX path of (target of first window as text)
    end tell
EOF
}

# Print the current Finder selection
function pfs() {
    osascript 2>&1 <<EOF
    tell application "Finder" to set the_selection to selection
    if the_selection is not {}
      repeat with an_item in the_selection
        log POSIX path of (an_item as text)
      end repeat
    end if
EOF
}

# Push the current Finder directory to the dirstack.
function pushdf() {
    pushd "$(pfd)" || return
}

# Remove .DS_Store files recursively in a directory.
function rmdstore() {
    find "${*:-.}" -type f -name .DS_Store -delete
}
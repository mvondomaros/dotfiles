[ -d /opt/homebrew/bin ] || return 1

# Set up homebrew.
if [[ -z "${HOMEBREW_PREFIX:-}" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Show the root installs with all deps.
brews() {
    local bluify_deps='
    BEGIN { blue = "\033[34m"; reset = "\033[0m" }
          { leaf = $1; $1 = ""; printf "%s%s%s%s\n", leaf, blue, $0, reset}
  '
    brew leaves | xargs brew deps --installed --for-each | awk "$bluify_deps"
}

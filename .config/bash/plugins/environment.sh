# Set the locale.
export LANG=en_US.UTF-8
export LC_CTYPE=$LANG

# Set paths.
for p in ~/bin ~/.local/bin; do
    [[ ! -d $p ]] && continue
    export PATH="$p:$PATH"
done

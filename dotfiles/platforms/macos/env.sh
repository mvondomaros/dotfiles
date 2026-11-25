# Homebrew also needs to be discoverable in noninteractive SSH sessions.
for _brew_prefix in /opt/homebrew /usr/local; do
    if [ -x "$_brew_prefix/bin/brew" ]; then
        _brew_path=$_brew_prefix/bin
        _brew_remaining=$PATH
        while :; do
            case $_brew_remaining in
                *:*) _brew_entry=${_brew_remaining%%:*}; _brew_remaining=${_brew_remaining#*:}; _brew_more=true ;;
                *) _brew_entry=$_brew_remaining; _brew_more=false ;;
            esac
            if [ "$_brew_entry" != "$_brew_prefix/bin" ]; then
                _brew_path=$_brew_path:$_brew_entry
            fi
            [ "$_brew_more" = true ] || break
        done
        PATH=$_brew_path
        break
    fi
done
export PATH
# Workstations query Slurm on the cluster over SSH; clusters use local squeue.
: "${SJOBS_HOST:=marc3a}"
export SJOBS_HOST
unset _brew_prefix _brew_path _brew_remaining _brew_entry _brew_more

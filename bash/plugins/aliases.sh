# Redefine ls
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=auto --icons=auto --hyperlink --group-directories-first'
    alias ll='ls --long --git --sort=Name'
    alias la='ls --long --git --sort=Name --all'
    alias l.='ls --long --git --sort=Name --list-dirs .*'
    alias ss='ls --long --sort=size'
    alias ssr='ls --long --sort=size --reverse'
    alias st='ls --long --sort=time'
    alias str='ls --long --sort=time --reverse'
    alias tree='ls --tree'
else
    if [ "$(uname -s)" = Darwin ]; then
        alias ls='ls -G'
    else
        alias ls='ls --color=auto --group-directories-first'
    fi
    alias ll='ls -lh'
    alias la='ls -lha'
    alias l.='ls -lha -d .*'
    alias ss='ls -lhs'
    alias ssr='ls -lhsr'
    alias st='ls -lht'
    alias str='ls -lhtr'
fi

# Prefer better tools under the familiar name; `command NAME` reaches the original.
if command -v btop >/dev/null 2>&1; then
    alias top='btop'
elif command -v htop >/dev/null 2>&1; then
    alias top='htop'
fi

# Mask builtins with better defaults
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias grep='grep --color=auto'
if command -v free >/dev/null 2>&1; then alias free='free -h'; fi
if [ "$(uname -s)" = Darwin ] && command -v trash >/dev/null 2>&1; then
    # rm moves files to the Trash; `command rm` deletes them. rm's usual flags
    # are accepted, and rm's checks for missing files and directories still apply.
    rm() {
        local recursive=false force=false flags status=0 file
        local -a options=() targets=()
        while [ "$#" -gt 0 ]; do
            case $1 in
                --) shift; break ;;
                -?*)
                    flags=${1#-}
                    while [ -n "$flags" ]; do
                        case ${flags:0:1} in
                            r|R|d) recursive=true ;;
                            f) force=true ;;
                            v) options=(-v) ;;
                            i|I) ;;
                            *) printf 'rm: unsupported option -%s (use command rm)\n' "${flags:0:1}" >&2; return 2 ;;
                        esac
                        flags=${flags:1}
                    done ;;
                *) break ;;
            esac
            shift
        done
        for file in "$@"; do
            if [ ! -e "$file" ] && [ ! -L "$file" ]; then
                [ "$force" = true ] || { printf 'rm: %s: No such file or directory\n' "$file" >&2; status=1; }
                continue
            fi
            if [ -d "$file" ] && [ ! -L "$file" ] && [ "$recursive" = false ]; then
                printf 'rm: %s: is a directory\n' "$file" >&2; status=1; continue
            fi
            case $file in -*) file=./$file ;; esac
            targets+=("$file")
        done
        if [ "${#targets[@]}" -gt 0 ]; then command trash ${options[@]+"${options[@]}"} "${targets[@]}" || status=$?; fi
        return "$status"
    }
else
    alias rm='rm -I'
fi

# Date helpers
alias timestamp='date "+%Y-%m-%d %H:%M:%S"'
alias datestamp='date "+%Y-%m-%d"'

# Abbreviations
alias lg='lazygit'


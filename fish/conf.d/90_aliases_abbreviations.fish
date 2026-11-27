if status is-interactive
    # Redefine ls.
    if type -q eza
        alias ls 'eza --color=auto --icons=auto --hyperlink --group-directories-first'
        alias ll 'ls --long --git --sort=Name'
        alias la 'ls --long --git --sort=Name --all'
        alias l. 'ls --long --git --sort=Name --list-dirs .*'
        alias ss 'ls --long --sort=size'
        alias ssr 'ls --long --sort=size --reverse'
        alias st 'ls --long --sort=time'
        alias str 'ls --long --sort=time --reverse'
        alias tree 'ls --tree'
    else
        if test (uname -s) = Darwin
            alias ls 'ls -G'
        else
            alias ls 'ls --color=auto --group-directories-first'
        end
        alias ll 'ls -lh'
        alias la 'ls -lha'
        alias l. 'ls -lha -d .*'
        alias ss 'ls -lhs'
        alias ssr 'ls -lhsr'
        alias st 'ls -lht'
        alias str 'ls -lhtr'
    end

    # Prefer better tools under the familiar name; `command NAME` reaches the original.
    if type -q btop
        alias top btop
    else if type -q htop
        alias top htop
    end

    # Mask builtins with better defaults. Fish's own grep wrapper adds color.
    alias mkdir 'mkdir -p'
    alias df 'df -h'
    alias du 'du -h'
    type -q free; and alias free 'free -h'
    if test (uname -s) = Darwin; and type -q trash
        # rm moves files to the Trash; `command rm` deletes them. rm's usual flags
        # are accepted, and rm's checks for missing files and directories still apply.
        function rm --description 'Move files to the Trash (command rm deletes)'
            set -l recursive false
            set -l force false
            set -l options
            set -l operands $argv
            while set -q operands[1]
                set -l arg $operands[1]
                if test "$arg" = --
                    set -e operands[1]
                    break
                end
                string match -qr -- '^-.' $arg; or break
                for flag in (string split '' -- (string sub --start 2 -- $arg))
                    switch $flag
                        case r R d
                            set recursive true
                        case f
                            set force true
                        case v
                            set options -v
                        case i I
                        case '*'
                            printf 'rm: unsupported option -%s (use command rm)\n' $flag >&2
                            return 2
                    end
                end
                set -e operands[1]
            end
            set -l code 0
            set -l targets
            for file in $operands
                if not test -e $file; and not test -L $file
                    if test $force = false
                        printf 'rm: %s: No such file or directory\n' $file >&2
                        set code 1
                    end
                    continue
                end
                if test -d $file; and not test -L $file; and test $recursive = false
                    printf 'rm: %s: is a directory\n' $file >&2
                    set code 1
                    continue
                end
                string match -q -- '-*' $file; and set file ./$file
                set -a targets $file
            end
            if set -q targets[1]
                command trash $options $targets; or set code $status
            end
            return $code
        end
    else
        alias rm 'rm -I'
    end

    # Date helpers.
    alias timestamp 'date "+%Y-%m-%d %H:%M:%S"'
    alias datestamp 'date "+%Y-%m-%d"'

    # Abbreviations.
    abbr -a lg lazygit

end

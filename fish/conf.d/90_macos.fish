if status is-interactive; and test (uname) = Darwin
    # Print the frontmost Finder directory.
    function pfd --description 'Print frontmost Finder directory'
        osascript -e 'tell application "Finder" to get POSIX path of (target of front window as text)' 2>/dev/null
    end

    # Change to the current Finder directory.
    function cdf --description 'cd to front Finder directory'
        set -l dir (pfd)
        test -n "$dir"; and cd $dir
    end

    # Open the current directory in Finder.
    function ofd --description 'Open current directory in Finder'
        open "$PWD"
    end

    # Quick Look preview of files.
    function peek --description 'Quick Look preview'
        if test (count $argv) -gt 0
            command -sq qlmanage; and qlmanage -p $argv >/dev/null 2>&1 &
        end
    end
end


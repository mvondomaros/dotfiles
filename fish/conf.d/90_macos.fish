if status is-interactive; and test (uname -s) = Darwin
    # Print the frontmost Finder directory.
    function pfd
        echo 'tell application "Finder"
                  return POSIX path of (target of first window as text)
              end tell' | osascript 2>/dev/null
    end

    # Change to the current Finder directory.
    function cdf
        cd (pfd); or return
    end

    # Open the current directory in Finder.
    function ofd
        open $PWD
    end

    # Take a quick look at a file using an appropriate viewer.
    function peek
        if test (count $argv) -gt 0
            qlmanage -p $argv >/dev/null 2>&1 &
        end
    end
end

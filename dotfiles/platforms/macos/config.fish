# Apple's setuid top ignores user terminfo locations, including ~/.terminfo.
function top --description 'Run macOS top with a system terminal definition'
    if test "$TERM" = xterm-kitty
        TERM=xterm-256color command top $argv
    else
        command top $argv
    end
end

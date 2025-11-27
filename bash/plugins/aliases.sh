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
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lh'
    alias la='ls -lha'
    alias l.='ls -lha -d .*'
    alias ss='ls -lhs'
    alias ssr='ls -lhsr'
    alias st='ls -lht'
    alias str='ls -lhtr'
fi

# Mask builtins with better defaults
alias mkdir='mkdir -p'
alias rm='rm -I'

# Date helpers
alias timestamp='date "+%Y-%m-%d %H:%M:%S"'
alias datestamp='date "+%Y-%m-%d"'

# Abbreviations
alias lg='lazygit'


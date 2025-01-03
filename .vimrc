" Set the runtime and packpath.
set runtimepath=~/.config/vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.config/vim/after
let &packpath = &runtimepath

" Set the viminfo file.
if !isdirectory($HOME . "/.cache/vim")
    call mkdir($HOME . "/.cache/vim", "p")
endif
set viminfofile=~/.cache/vim/.viminfo

" Better defaults were introduced in vim 7, but they only load for a missing vimrc
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" Kickstart
source ~/.config/vim/kickstart.vim

" General Settings
set nobackup
set nowritebackup
set noswapfile
set autowrite
set lazyredraw
set shortmess+=I
set virtualedit+=block
set wildmode=list:full
set foldmethod=marker

" Editor
set title

" Whitespace
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set shiftround
set smartindent

" Make search more sane
set showmatch
set gdefault
" This unsets the "last search pattern" register by hitting return
nnoremap <CR> :noh<CR><CR>:<backspace>

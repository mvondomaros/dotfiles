" Standalone fallback: no submodules, plugins, downloads, or compiler needed.
set nocompatible
syntax enable
filetype plugin indent on
set number
set hidden
set backspace=indent,eol,start
set expandtab shiftwidth=4 softtabstop=4 tabstop=4
set ignorecase smartcase incsearch hlsearch
set splitbelow splitright
set wildmenu
set ruler
set laststatus=2
set encoding=utf-8
let mapleader = " "
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <leader>w :write<CR>
if has('persistent_undo')
  let s:state = empty($XDG_STATE_HOME) ? expand('~/.local/state') : $XDG_STATE_HOME
  let &undodir = s:state . '/vim/undo//'
  if isdirectory(s:state . '/vim/undo')
    set undofile
  endif
endif
if !empty($XDG_CONFIG_HOME)
  let s:config = $XDG_CONFIG_HOME
else
  let s:config = expand('~/.config')
endif
if isdirectory(s:config . '/vim-colors')
  execute 'set runtimepath^=' . fnameescape(s:config . '/vim-colors')
  if exists('+termguicolors') && ($COLORTERM ==# 'truecolor' || $TERM =~# 'kitty')
    set termguicolors
  endif
  colorscheme ayu_light
endif
if filereadable(s:config . '/dotfiles/local/vimrc')
  execute 'source ' . fnameescape(s:config . '/dotfiles/local/vimrc')
endif

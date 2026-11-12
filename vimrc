" Standalone fallback: no external plugins, downloads, or compiler needed.
set nocompatible
let g:loaded_spellfile_plugin = 1
set encoding=utf-8
syntax enable
filetype plugin indent on
set number
set hidden
set confirm
set backspace=indent,eol,start
set autoindent expandtab shiftround shiftwidth=4 softtabstop=4 tabstop=4
set ignorecase smartcase incsearch hlsearch
set splitbelow splitright
set wildmenu wildmode=longest:full,full
set scrolloff=4 sidescrolloff=8
set linebreak
set ruler
set laststatus=2

" Match the full Neovim setup: prefix = subject, next letter = action.
let mapleader = " "
let maplocalleader = " "
nnoremap <silent> <Esc> :nohlsearch<CR>
nnoremap <leader>ff :find<Space>
nnoremap <leader>fo :edit<Space>
nnoremap <leader>fe :Explore<CR>
nnoremap <leader>fs :write<CR>
nnoremap <leader>fn :enew<CR>
nnoremap <leader>bl :ls<CR>:buffer<Space>
nnoremap <leader>bb :buffer #<CR>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :confirm bdelete<CR>
nnoremap <leader>wh :split<CR>
nnoremap <leader>wv :vsplit<CR>
nnoremap <leader>wc :close<CR>
nnoremap <leader>hs :help<Space>
nnoremap <leader>hk :FallbackHelp<CR>
nnoremap <leader>uw :setlocal wrap!<CR>
nnoremap <leader>us :setlocal spell!<CR>
nnoremap <leader>qa :confirm qall<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

command! FallbackHelp echo join([
      \ 'Vim fallback: Space, then subject + action',
      \ 'Files:   ff find (Tab completes paths), fo open, fe explorer, fs save, fn new',
      \ 'Buffers: bl list/select, bb back, bn next, bp previous, bd delete',
      \ 'Windows: wh horizontal split, wv vertical split, wc close; Ctrl-h/j/k/l move',
      \ 'Help:    hs help search (Tab completes tags), hk key reference',
      \ 'UI:      uw wrap toggle, us spelling toggle; qa quit all (confirm changes)',
      \ 'Native:  / search, n/N repeat, gf open file under cursor, Ctrl-o/i jump back/forward',
      \ 'Native:  :vimgrep /pattern/j files populates quickfix; :copen, :cnext, :cprevious',
      \ 'Insert:  Ctrl-n/p word completion, Ctrl-x Ctrl-f filename completion',
      \ ], "\n")

" The installer creates this directory; startup also works without it.
let s:state = empty($XDG_STATE_HOME) ? expand('~/.local/state') : $XDG_STATE_HOME
let g:netrw_home = s:state . '/vim'
if has('persistent_undo')
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
if filereadable(s:config . '/vim-colors/colors/ayu_light.vim')
  execute 'set runtimepath^=' . fnameescape(s:config . '/vim-colors')
  if exists('+termguicolors') && ($COLORTERM ==# 'truecolor' || $TERM =~# 'kitty')
    set termguicolors
  endif
  colorscheme ayu_light
endif
if filereadable(s:config . '/dotfiles/local/vimrc')
  execute 'source ' . fnameescape(s:config . '/dotfiles/local/vimrc')
endif

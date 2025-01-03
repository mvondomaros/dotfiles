" Bootstrap vim-plug.
let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Install plugins.
call plug#begin()
    Plug 'tpope/vim-sensible'
    Plug 'catppuccin/vim', { 'as': 'catppuccin' }
    Plug 'itchyny/lightline.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
call plug#end()

" Colorscheme
set termguicolors
colorscheme catppuccin_mocha

" Statusline
set laststatus=2
let g:lightline = { 'colorscheme': 'catppuccin_mocha' }

" Options
set autoindent
set autowriteall
set background=dark
set nobackup
set breakindent
set clipboard=unnamedplus
set cursorline
set noerrorbells
set expandtab
set foldmethod=marker
set ignorecase
set lazyredraw
set relativenumber
set scrolloff=8
set shiftround
set shiftwidth=4
set sidescrolloff=8
set signcolumn=yes
set smartcase
set smartindent
set smarttab
set smoothscroll
set softtabstop=4
set splitbelow
set splitright
set noswapfile
set tabstop=4
set title
set undofile
set novisualbell
set wrap
set nowritebackup

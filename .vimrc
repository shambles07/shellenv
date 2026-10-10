" Required Settings for Vundle plugin manager
set nocompatible
syntax on
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
        Plugin 'VundleVim/Vundle.vim'
        Plugin 'ParamagicDev/vim-medic_chalk'
		Plugin 'christoomey/vim-tmux-navigator'
call vundle#end()
filetype plugin indent on

" Custom Settings
colorscheme medic_chalk
set nu
set sw=4
set tabstop=4
set ignorecase

" Use persistent history.
if !isdirectory("/tmp/.vim-undo-dir")
    call mkdir("/tmp/.vim-undo-dir", "", 0700)
endif
set undodir=/tmp/.vim-undo-dir
set undofile

" Ctrl+m = Toggle line numbers
map <C-m> :set nu!<CR>
" Ctrl+n = Toggle relative line numbers
map <C-n> :set rnu!<CR>


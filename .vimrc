" Required Settings for Vundle plugin manager
set nocompatible
syntax on
filetype off
" plugins are git submodules in ~/.vim/bundle: only load the ones checked out
let s:bundle = expand('~/.vim/bundle')
if isdirectory(s:bundle . '/Vundle.vim')
	let &rtp .= ',' . s:bundle . '/Vundle.vim'
	call vundle#begin(s:bundle)
	for s:plugin in [
		\ 'VundleVim/Vundle.vim',
		\ 'ParamagicDev/vim-medic_chalk',
		\ 'christoomey/vim-tmux-navigator',
		\ 'tpope/vim-fugitive',
		\ ]
		if isdirectory(s:bundle . '/' . fnamemodify(s:plugin, ':t'))
			execute 'Plugin' string(s:plugin)
		endif
	endfor
	call vundle#end()
endif
filetype plugin indent on

" Custom Settings
silent! colorscheme medic_chalk
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


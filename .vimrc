" Required Settings for Vundle plugin manager
set nocompatible
syntax on
filetype off
" location of this repo, found by resolving the ~/.vimrc symlink, so plugins
" load from the repo even if ~/.vim isn't linked to it
let s:shellenv = fnamemodify(resolve(expand('<sfile>:p')), ':h')
" plugins are git submodules in .vim/bundle: only load the ones checked out
let s:bundle = s:shellenv . '/.vim/bundle'
if isdirectory(s:bundle . '/Vundle.vim')
	let &rtp .= ',' . s:bundle . '/Vundle.vim'
	call vundle#begin(s:bundle)
	for s:plugin in [
		\ 'VundleVim/Vundle.vim',
		\ 'ParamagicDev/vim-medic_chalk',
		\ 'christoomey/vim-tmux-navigator',
		\ 'tpope/vim-fugitive',
		\ 'fatih/vim-go',
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

" Use persistent history, kept per user: a shared directory in /tmp is unusable
" by everyone else once one user (e.g. root via sudo) has created it
if has('persistent_undo')
    let s:undodir = (empty($XDG_STATE_HOME) ? $HOME . '/.local/state' : $XDG_STATE_HOME) . '/vim/undo'
    if !isdirectory(s:undodir)
        call mkdir(s:undodir, 'p', 0700)
    endif
    let &undodir = s:undodir
    set undofile
endif

" Ctrl+m = Toggle line numbers
map <C-m> :set nu!<CR>
" Ctrl+n = Toggle relative line numbers
map <C-n> :set rnu!<CR>


execute pathogen#infect()
syntax on
filetype plugin indent on
set shiftwidth=4
set tabstop=4
let mapleader=" "
let maplocalleader=","
set hlsearch
set incsearch
nnoremap <silent> <leader>c :nohl<CR><C-l>
set clipboard=unnamed
nnoremap <F5> "=system('date -u "+%a, %d %b %Y %T %z"')[:-2]<CR>P
inoremap <F5> <C-R>=system('date -u "+%a, %d %b %Y %T %z"')[:-2]<CR>

" Pymode config
let g:pymode_rope_completion = 1
let g:pymode_rope_complete_on_dot = 0

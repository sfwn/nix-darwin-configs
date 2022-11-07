set mouse=a
set number
set relativenumber
set showmatch
set termguicolors
let g:ctrlp_map = '<c-p>'
"set showtabline=2
"colorscheme PaperColor
"colorscheme dracula
"set background=light
set ignorecase

" tab
set tabstop=4 "Number of spaces that a <Tab> in the file counts for.
set softtabstop=4
set shiftwidth=4
set expandtab "To insert a real tab when 'expandtab' is on, use CTRL-V<Tab>.
set smarttab
" indent
set autoindent
set smartindent

set cursorline


let mapleader = ";"

""" terminal
set splitright
set splitbelow
nmap <leader>t :vsplit term://zsh<CR>i

""" fzf
"nnoremap <Leader>fl :Lines<CR>
"nnoremap <Leader>ff :Rg<CR>
"nnoremap <Leader>fo :Files<CR>

" copy to system clipboard
vmap <C-c> "+y
vmap <D-c> "+y
map <D-v> "+p<CR>
map! <D-v> <C-R>+
tmap <D-v> <C-R>+

" quick exit
nmap <leader>q :q<CR>
nmap <leader>g :G<CR>

" quickfix
nnoremap <silent> cn :cnext<CR>
nnoremap <silent> cp :cprev<CR>
nnoremap <silent> co :copen<CR>

" complete
" set completeopt=menu,menuone,noselect
"set completeopt=menu,menuone

" from coc
set nobackup
set nowritebackup
set updatetime=300
set signcolumn=yes

inoremap <silent> <A-BS> <C-w>
inoremap <silent> <S-Enter> <Esc>o

" 2 for git signs and diagnostics, 4 for breakpoint and others
set signcolumn=auto:3-5

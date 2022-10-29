set mouse=a
set number
set relativenumber
set showmatch
set termguicolors
let g:ctrlp_map = '<c-p>'
set showtabline=2
"colorscheme PaperColor
colorscheme dracula
set background=light
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

""" go debug
let g:go_debug_mappings = {
    \ '(go-debug-continue)': {'key': 'F5', 'arguments': '<nowait>'},
    \ '(go-debug-next)': {'key': 'F8', 'arguments': '<nowait>'},
    \ '(go-debug-step)': {'key': 'F7'},
    \ '(go-debug-print)': {'key': 'p'},
\}
map <leader>ds :GoDebugStart<cr>
map <leader>dt :GoDebugStop<cr>
map <leader>db :GoDebugBreakpoint<cr>

""" fzf
"nnoremap <Leader>fl :Lines<CR>
"nnoremap <Leader>ff :Rg<CR>
"nnoremap <Leader>fo :Files<CR>

" copy to system clipboard
vmap <C-c> "+y

" quick exit
nmap <leader>q :q<CR>
nmap <leader>g :G<CR>

" quickfix
nnoremap cn :cnext<CR>
nnoremap cp :cprev<CR>
nnoremap co :copen<CR>

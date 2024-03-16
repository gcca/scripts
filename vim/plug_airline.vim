Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

let g:airline#extensions#tabline#enabled = 1

"  serene  badwolf  luna  everforest  powerlineish
let g:airline_theme='badwolf'

autocmd BufDelete * call airline#extensions#tabline#buflist#invalidate()

let g:airline#extensions#hunks#enabled = 0
let g:airline_detect_iminsert=1

Plug 'ryanoasis/vim-devicons'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'

" simpleblack

let g:lightline = {
  \ 'colorscheme': 'solarized',
  \ 'active': {
  \   'left': [['mode','paste'], ['readonly','absolutepath','gitbranch','modified']],
  \ },
  \ 'tabline': {
  \   'left': [['buffers']], 'right':[],
  \ },
  \ 'component_expand': {
  \   'buffers': 'lightline#bufferline#buffers'
  \ },
  \ 'component_type': {
  \   'buffers': 'tabsel'
  \ },
  \ 'component_function': {
  \   'gitbranch': 'FugitiveHead'
  \ },
  \ 'separator': {'left': '','right':''},
  \ 'subseparator': {'left':'','right':''},
  \ 'component': {
  \   'lineinfo': '%2l:%-1v ',
  \ },
  \ }

let g:lightline#bufferline#enable_devicons = 1
let g:lightline#bufferline#unicode_symbols = 1

set showtabline=2

autocmd BufWritePost,TextChanged,TextChangedI * call lightline#update()

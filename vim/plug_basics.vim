Plug 'moll/vim-bbye'

Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_working_path_mode = '.'
let g:ctrlp_custom_ignore = '\v[\/](build|plugged|env|.cache|.DS_Store|homebrew|docs|api-doc|target|__pycache__|htmlcov|node_modules|.*media.*|.*\.zip|.*-env)$'

Plug 'scrooloose/nerdcommenter'

Plug 'bfrg/vim-cpp-modern'
let g:cpp_attributes_highlight = 1
let g:cpp_member_highlight = 1

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'kelly-lin/telescope-ag'

"Plug 'nvim-lua/plenary.nvim'
"Plug 'nvim-tree/nvim-web-devicons'
"Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'
autocmd VimEnter * lua require('neotree-plug')

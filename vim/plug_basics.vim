Plug 'moll/vim-bbye'

"Plug 'ctrlpvim/ctrlp.vim'
"let g:ctrlp_working_path_mode = '.'
"let g:ctrlp_custom_ignore = '\v[\/](build|plugged|env|.cache|.DS_Store|homebrew|docs|api-doc|target|__pycache__|htmlcov|node_modules|.*media.*|.*\.zip|.*-env)$'

Plug 'scrooloose/nerdcommenter'

Plug 'bfrg/vim-cpp-modern'
let g:cpp_attributes_highlight = 1
let g:cpp_member_highlight = 1

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'kelly-lin/telescope-ag'
autocmd VimEnter * lua require('telescope-plug')
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<CR>
noremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<CR>
noremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<CR>
noremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<CR>


"Plug 'nvim-lua/plenary.nvim'
"Plug 'nvim-tree/nvim-web-devicons'
"Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'
autocmd VimEnter * lua require('neotree-plug')
nnoremap <leader>ny :Neotree toggle<CR>:wincmd p<CR>
nnoremap <leader>nt :Neotree reveal<CR>:wincmd p<CR>

function! s:neotree()
  hi NeoTreeNormalNC guibg=NONE
  hi NeoTreeNormal guibg=NONE
endfunction
autocmd VimEnter * call s:neotree()



Plug 'echasnovski/mini.indentscope', { 'branch': 'stable' }

function! s:mini_indentscope()
lua << EOF
  require('mini.indentscope').setup({
    draw = {
      priority = 2,
    },
    symbol = '▏',
  })
EOF
hi MiniIndentscopeSymbol guifg=#333000
endfunction

autocmd VimEnter * call s:mini_indentscope()

function! s:start_neot()
lua << EOF
vim.opt.fillchars:append({ vert = " " })
vim.schedule(function()
    vim.cmd("Neotree filesystem reveal")
    vim.cmd("wincmd s")
    vim.cmd("wincmd j")
    vim.cmd("resize 8")
    vim.cmd("wincmd l")
    local timer = vim.loop.new_timer()
    timer:start(100, 0, vim.schedule_wrap(function()
        vim.cmd("Neotree buffers reveal_force_cwd")
        vim.cmd("wincmd l")
    end))
end)
EOF
endfunction
autocmd VimEnter * call s:start_neot()

--: {{{ Lazy
-- vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)
--: }}} Lazy

-- vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

--: {{{ AutoCmd
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        vim.cmd [[hi SignColumn guibg=NONE]]
        vim.cmd [[hi FoldColumn guibg=NONE]]
        vim.cmd [[hi LineNr guibg=NONE]]
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = "%s/\\s\\+$//e",
})
--: }}} AutoCmd

--: {{{ Custom commands
--: {{{ DarkMode func
vim.api.nvim_create_user_command('DarkMode', function(opts)
    vim.cmd [[hi Normal guibg=black]]
    vim.cmd [[hi NormalNC guibg=black]]
    vim.cmd [[hi SignColumn guibg=black]]

    vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#070707', bg = NONE, gui = NONE })
    vim.api.nvim_set_hl(0, 'VertSplit', { fg = 'black', bg = 'black', gui = NONE })

    vim.cmd [[hi NeotreeNormal guibg=black]]
    vim.api.nvim_set_hl(0, 'NeotreeEndOfBuffer', { bg = 'black', fg = 'black' })
end, {})
--: }}} DarkMode func

--: {{{ TransparentMode func
vim.api.nvim_create_user_command('TransparentMode', function(opts)
    vim.cmd [[hi Normal guibg=NONE]]
    vim.cmd [[hi NormalNC guibg=NONE]]
    vim.cmd [[hi NormalSB guibg=NONE]]
    vim.cmd [[hi NormalFloat guibg=NONE]]

    vim.cmd [[hi SignColumn guibg=NONE]]
    vim.cmd [[hi FoldColumn guibg=NONE]]
    vim.cmd [[hi LineNr guibg=NONE]]

    vim.cmd [[hi DiagnosticSignError guibg=NONE]]
    vim.cmd [[hi DiagnosticSignHint guibg=NONE]]

    --vim.cmd [[hi EndOfBuffer guibg=NONE]]

    vim.cmd [[hi NeotreeNormal guibg=NONE]]
    vim.cmd [[hi NeotreeNormalNC guibg=NONE]]
    vim.cmd [[hi NormalFloat guibg=NONE]]
    vim.cmd [[hi CocInlayHint guibg=NONE gui=italic]]
    --vim.cmd [[hi NeotreeEndOfBuffer guibg=NONE]]



    vim.cmd [[hi NeotreeNormal guibg=NONE]]
    vim.cmd [[hi NeotreeNormalNC guibg=NONE]]
    vim.cmd [[hi NormalFloat guibg=NONE]]
    vim.cmd [[hi CocInlayHint guibg=NONE gui=italic]]
    --vim.cmd [[hi NeotreeEndOfBuffer guibg=NONE]]
    vim.cmd [[hi ZenBg guibg=NONE]]
end, {})
--: }}} TransparentMode func

--: {{{ ShowCursorLine func
vim.api.nvim_create_user_command('ShowCursorLine', function(opts)
    vim.cmd [[
        hi! link CursorLineNr CursorLine
        hi! link CursorLineSign CursorLine
        set cursorline
    ]]
end, {})
--: }}} ShowCursorLine func

--: {{{ StatusColumn Funcs
vim.api.nvim_create_user_command('SColumn', function()
    if vim.o.numberwidth == 4 then
        vim.o.statuscolumn = '%l %C %s'
        vim.o.foldcolumn = '3'
        vim.o.signcolumn = 'yes:3'
        vim.o.numberwidth = 3
    else
        vim.o.statuscolumn = '   %l %C %s      '
        vim.o.foldcolumn = '5'
        vim.o.signcolumn = 'yes:5'
        vim.o.numberwidth = 4
    end
end, {})

--: }}} StatusColumn Funcs

--: {{{ ReplaceUUIDs func
vim.api.nvim_create_user_command('ReplaceUUIDs', function()
    vim.cmd [[
        s/\w\{8\}-\w\{4\}-\w\{4\}-\w\{4\}-\w\{12\}/HERE_UUID/g
        s/HERE_UUID/\=substitute(system('python -c "from uuid import uuid4;print(uuid4())"'),'\n','','g')/g
    ]]
end, {})
--: }}} ReplaceUUIDs func

--: {{{ GenNM func
vim.api.nvim_create_user_command('GenNM', function(opts)
    local args = {}
    for str in string.gmatch(opts.args, "%S+") do
        table.insert(args, str)
    end

    local N, M

    if #args == 1 then
        N = tonumber(args[1])
        M = nil
    elseif #args == 2 then
        N = tonumber(args[1])
        M = tonumber(args[2])
    else
        print("Error: El comando necesita uno o dos números como argumentos.")
        return
    end

    if M then
        vim.cmd(string.format("put =map(range(%d, %d), 'v:val.\\\",\\\"')", N, M))
    else
        vim.cmd(string.format("put =map(range(0, %d), 'v:val.\\\",\\\"')", N))
    end
end, {
    nargs = '+',
})
--: }}} GenNM func

--: {{{ FormatAWSCreds func
vim.api.nvim_create_user_command('FormatAWSCreds', function()
    vim.cmd [[
    s/export \(\w\+\)=\(\(["+/]\|\w\)\+\)/set \1 \2
    ]]
end, {})
--: }}} FormatAWSCreds func

--: {{{ Clipboard buffer replaced
function ReplaceBufferWithClipboard()
    vim.api.nvim_command('%d')
    vim.api.nvim_command('normal! "+p')
end

vim.api.nvim_create_user_command('RBClip', ReplaceBufferWithClipboard, {})
vim.keymap.set('n', '<leader>kw', ':RBClip<CR>', { noremap = true, silent = true })
--: }}} Clipboard buffer replaced

--: }}} Custom commands

--: {{{ Diagnostic signs

-- Configuración de iconos de diagnóstico
-- vim.diagnostic.config({
--    virtual_text = {
--       prefix = "●",
--    },
--    signs = true,
--    update_in_insert = false,
--    severity_sort = true,
-- })
--
-- Definir signos personalizados
-- local signs = {
--    Error = "✖",
--    Warn = "⚠",
--    Info = "ℹ",
--    Hint = "➤",
-- }
--
-- for type, icon in pairs(signs) do
--    local hl = "DiagnosticSign" .. type
--    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '󰌵',
            [vim.diagnostic.severity.INFO] = '',
        },
    },
})

-- vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
-- vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
-- vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
-- vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

--: }}} Diagnostic signs

--: {{{ HSL Util
local function hue2rgb(p, q, t)
    if t < 0 then
        t = t + 1
    end
    if t > 1 then
        t = t - 1
    end
    if t < 1 / 6 then
        return p + (q - p) * 6 * t
    end
    if t < 1 / 2 then
        return q
    end
    if t < 2 / 3 then
        return p + (q - p) * (2 / 3 - t) * 6
    end
    return p
end

local function hslToRgb(h, s, l)
    local r, g, b

    if s == 0 then
        r, g, b = l, l, l -- achromatic
    else
        local q
        if l < 0.5 then
            q = l * (1 + s)
        else
            q = l + s - l * s
        end
        local p = 2 * l - q

        r = hue2rgb(p, q, h + 1 / 3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1 / 3)
    end

    return r * 255, g * 255, b * 255
end

local function hslToHex(h, s, l)
    local r, g, b = hslToRgb(h / 360, s / 100, l / 100)
    return string.format("#%02x%02x%02x", r, g, b)
end
--: }}} HSL Util

require("lazy").setup({
    --: {{{ Specs begin
    spec = {
        --: }}} Specs begin
        -- --: {{{ Themes
        -- --: {{{ Solarized Osaka
        -- {
        --     "craftzdog/solarized-osaka.nvim",
        --     -- lazy = false,
        --     priority = 1000,
        --     -- config = function()
        --     --     -- vim.cmd([[TransparentMode]])
        --     --     vim.cmd([[colorscheme solarized-osaka]])
        --     --     -- vim.api.nvim_set_hl(0, 'LineNr', { fg = hslToHex(45, 100, 11) })
        --     --     -- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
        --     --     -- vim.api.nvim_set_hl(0, 'FoldColumn', { fg = hslToHex(45, 100, 15) })
        --     -- end,
        -- },
        -- --: }}} Solarized Osaka
        -- --: {{{ Tokyonight
        -- {
        --     "folke/tokyonight.nvim",
        --     priority = 1000,
        --     -- config = function()
        --     --     vim.cmd([[colorscheme tokyonight]])
        --     -- end,
        -- },
        -- --: }}} Tokyonight
        -- --: {{{ Catppuccino
        -- {
        --     'catppuccin/nvim',
        --     priority = 1000,
        -- },
        -- --: }}} Catppuccino
        -- --: {{{ Kanagawa
        -- {
        --     'rebelot/kanagawa.nvim',
        --     priority = 1000,
        -- },
        -- --: }}} Kanagawa
        -- --: {{{ One Dark Pro
        -- {
        --     'olimorris/onedarkpro.nvim',
        --     priority = 1000,
        --     -- config = function()
        --     --     --vim.cmd.colorscheme onedarkpro'
        --     -- end,
        -- },
        -- --: }}} One Dark Pro
        -- --: {{{ One Dark
        -- {
        --     'navarasu/onedark.nvim',
        --     -- lazy = false,
        --     priority = 1000,
        --     -- config = function()
        --     --     local onedark = require 'onedark'
        --     --     onedark.setup { style = 'deep' }
        --     --     onedark.load()
        --     -- end,
        -- },
        -- --: }}} One Dark
        -- --: {{{ Everforest
        -- {
        --     'neanias/everforest-nvim',
        --     version = false,
        --     lazy = false,
        --     priority = 1000,
        --     -- config = function()
        --     --     local everforest = require 'everforest'
        --     --     everforest.setup {
        --     --         background = 'hard',
        --     --     }
        --     --     everforest.load()
        --     -- end,
        -- },
        -- --: }}} Everforest
        -- --: {{{ One Monokai
        -- {
        --     'cpea2506/one_monokai.nvim',
        --     lazy = false,
        --     -- priority = 1000,
        --     -- config = function()
        --     --     local om = require 'one_monokai'
        --     --     om.setup {
        --     --         transparent = true,
        --     --         colors = {},
        --     --         themes = function(_) --(colors)
        --     --             return {}
        --     --         end,
        --     --         italics = true,
        --     --     }
        --     --     vim.cmd.colorscheme 'one_monokai'
        --     -- end,
        -- },
        -- --: }}} One Monokai
        -- --: {{{ Rose Pine
        -- {
        --     "rose-pine/neovim",
        --     name = "rose-pine",
        --     lazy = false,
        --     priority = 1000,
        --     -- config = function()
        --     --     require 'rose-pine'.setup {
        --     --         variant = 'moon',
        --     --         dark_variant = 'moon',
        --     --     }
        --     --     vim.cmd.colorscheme 'rose-pine-main'
        --     --     -- vim.cmd [[TransparentMode]]
        --     -- end,
        -- },
        -- --: }}} Rose Pine
        -- --: {{{ Nightfox
        -- {
        --     'EdenEast/nightfox.nvim',
        --     lazy = false,
        --     priority = 1000,
        --     -- config = function()
        --     --     require('nightfox').setup({
        --     --         options = {
        --     --             transparent = true,
        --     --             styles = {
        --     --                 comments = 'italic',
        --     --                 keywords = 'bold',
        --     --                 types = 'italic', --'italic,bold',
        --     --             }
        --     --         }
        --     --     })
        --     --     vim.cmd.colorscheme 'terafox'
        --     --     vim.cmd [[TransparentMode]]
        --     -- end,
        -- },
        -- --: }}} Nightfox
        -- --: {{{ Ayu
        -- {
        --     'ayu-theme/ayu-vim',
        --     lazy = false,
        --     priority = 1000,
        --     config = function()
        --         vim.cmd [[colorscheme ayu | TransparentMode]]
        --         -- vim.cmd [[hi WinSeparator guifg=#2a2a2a guibg=NONE]]
        --         vim.cmd([[highlight! link WinSeparator LineNr]])
        --         vim.cmd([[highlight! link FoldColumn LineNr]])
        --     end,
        -- },
        -- --: }}} Ayu
        -- --: }}} Themes
        -- --: {{{ Telescope
        -- {
        --     "nvim-telescope/telescope.nvim",
        --     dependencies = { 'nvim-lua/plenary.nvim' },
        --     config = function()
        --         local telescope = require 'telescope'
        --         telescope.setup {
        --             pickers = {
        --                 find_files = {
        --                     hidden = true,
        --                     no_ignore = true,
        --                 },
        --                 colorscheme = {
        --                     enable_preview = true
        --                 }
        --             },
        --             defaults = {
        --                 file_ignore_patterns = {
        --                     "build/",
        --                     "dist/",
        --                     "__pycache__",
        --                     "%.egg%-info/",
        --                     "node_modules/",
        --                     ".git/",
        --                     ".DS_Store/",
        --                     ".cache/",
        --                 },
        --                 layout_config = {
        --                     prompt_position = "top",
        --                 },
        --             },
        --             extensions = {
        --                 aerial = {
        --                     col1_width = 4,
        --                     col2_width = 30,
        --                     format_symbol = function(symbol_path, filetype)
        --                         if filetype == "json" or filetype == "yaml" then
        --                             return table.concat(symbol_path, ".")
        --                         else
        --                             return symbol_path[#symbol_path]
        --                         end
        --                     end,
        --                     show_columns = "both",
        --                 },
        --             },
        --         }
        --
        --         telescope.load_extension 'aerial'
        --
        --         vim.cmd([[nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<CR>]])
        --         vim.cmd([[nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<CR>]])
        --         vim.cmd([[nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<CR>]])
        --         vim.cmd([[nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<CR>]])
        --     end,
        -- },
        -- --: }}} Telescope
        -- --: {{{ ZenMode
        -- {
        --     "folke/zen-mode.nvim",
        --     opts = {
        --         window = {
        --             width = .77,
        --         },
        --     },
        -- },
        -- --: }}} ZenMode
        -- --: {{{ Edgy
        -- {
        --     'folke/edgy.nvim',
        --     event = 'VeryLazy',
        --     init = function()
        --         vim.opt.laststatus = 3
        --         vim.opt.splitkeep = 'screen'
        --     end,
        --     config = function()
        --         local opts = {
        --             left = {
        --                 {
        --                     title = 'Project',
        --                     ft = 'neo-tree',
        --                     -- filter = function(buf)
        --                     --     return vim.b[buf].neo_tree_source == 'filesystem'
        --                     -- end,
        --                     pinned = true,
        --                     collapsed = false,
        --                     open = 'NvimTreeOpen',
        --                     size = { height = 0.55 },
        --                     wo = {
        --                         statuscolumn = '',
        --                         foldcolumn = '0',
        --                         signcolumn = 'no',
        --                     },
        --                 },
        --                 {
        --                     title = 'Workspace',
        --                     ft = 'neo-tree',
        --                     -- filter = function(buf)
        --                     --     return vim.b[buf].neo_tree_source == 'buffers'
        --                     -- end,
        --                     pinned = true,
        --                     collapsed = false,
        --                     open = 'NvimTreeOpen',
        --                     size = { height = 0.25 },
        --                     wo = {
        --                         statuscolumn = '',
        --                         foldcolumn = '0',
        --                         signcolumn = 'no',
        --                     },
        --                 },
        --                 {
        --                     title = "SCM",
        --                     ft = "neo-tree",
        --                     -- filter = function(buf)
        --                     --     return vim.b[buf].neo_tree_source == "git_status"
        --                     -- end,
        --                     pinned = true,
        --                     collapsed = false,
        --                     open = "NvimTreeOpen",
        --                     wo = {
        --                         statuscolumn = '',
        --                         foldcolumn = '0',
        --                         signcolumn = 'no',
        --                     },
        --                 },
        --                 --'neo-tree',
        --             },
        --             -- wo = {
        --             --     winbar = false,
        --             --     signcolumn = 'yes',
        --             -- },
        --         }
        --
        --         local vtside = {
        --             {
        --                 -- title = function()
        --                 --     local buf_name = vim.api.nvim_buf_get_name(0) or "[No Name]"
        --                 --     return vim.fn.fnamemodify(buf_name, ":t")
        --                 -- end,
        --                 title = 'View',
        --                 ft = "Outline",
        --                 pinned = true,
        --                 collapsed = false,
        --                 open = "AerialOpen",
        --                 -- size = { height = 0.65 },
        --                 --size = { width = 0.35 },
        --                 wo = {
        --                     statuscolumn = '',
        --                 },
        --             },
        --             {
        --                 title = "Term",
        --                 ft = "toggleterm",
        --                 -- size = { height = 0.35 },
        --                 --size = { width = 0.6 },
        --                 filter = function(_, win) --(buf, win)
        --                     return vim.api.nvim_win_get_config(win).relative == ""
        --                 end,
        --                 -- pinned = true,
        --                 -- collapsed = false,
        --                 -- open = "ToggleTerm",
        --                 wo = {
        --                     statuscolumn = '',
        --                 },
        --             },
        --         }
        --
        --         local width = vim.api.nvim_get_option('columns')
        --         if width < 167 then
        --             opts.options = {
        --                 left = { size = 24 },
        --                 bottom = { size = 8 },
        --             }
        --             opts.bottom = vtside
        --
        --             vtside[1].size = { width = 0.4 }
        --             vtside[2].size = { width = 0.6 }
        --         elseif width < 195 then
        --             opts.options = {
        --                 left = { size = 26 },
        --                 right = { size = 36 },
        --             }
        --             opts.right = vtside
        --
        --             vtside[1].size = { height = 0.5 }
        --             vtside[2].size = { height = 0.5 }
        --         else
        --             opts.options = {
        --                 left = { size = 31 },
        --                 right = { size = 31 },
        --             }
        --             opts.right = vtside
        --
        --             vtside[1].size = { height = 0.65 }
        --             vtside[2].size = { height = 0.35 }
        --         end
        --
        --         require 'edgy'.setup(opts)
        --
        --         vim.keymap.set('n', '<leader>ed', function()
        --             require 'edgy'.toggle()
        --         end, { silent = true })
        --     end,
        -- },
        -- --: }}} Edgy
        --: {{{ Aerial
        {
            'stevearc/aerial.nvim',
            opts = {},
            dependencies = {
                {
                    "nvim-treesitter/nvim-treesitter",
                    build = ":TSUpdate",
                    config = function()
                        require "nvim-treesitter.config".setup({
                            ensure_installed = { "c", "cpp", "cmake", "lua", "diff", "gitignore", "fish", "htmldjango", "python" },
                        })
                    end,
                },
                "nvim-tree/nvim-web-devicons"
            },
        },
        --: }}} Aerial
        -- --: {{{ Nvim-Tree
        -- {
        --     "nvim-tree/nvim-tree.lua",
        --     dependencies = {
        --         "nvim-tree/nvim-web-devicons",
        --     },
        --     config = function()
        --         require("nvim-tree").setup({
        --             sort = {
        --                 sorter = "case_sensitive",
        --             },
        --             view = {
        --                 width = 30,
        --                 side = "left",
        --                 signcolumn = "no",
        --             },
        --             -- renderer = {
        --             --     highlight_git = true,
        --             --     highlight_opened_files = "all",
        --             --     indent_markers = {
        --             --         enable = true,
        --             --     },
        --             --     icons = {
        --             --         show = {
        --             --             file = true,
        --             --             folder = true,
        --             --             folder_arrow = true,
        --             --             git = true,
        --             --         },
        --             --         glyphs = {
        --             --             default = "",
        --             --             symlink = "",
        --             --             folder = {
        --             --                 arrow_closed = "",
        --             --                 arrow_open = "",
        --             --                 default = "",
        --             --                 open = "",
        --             --                 empty = "",
        --             --                 empty_open = "",
        --             --                 symlink = "",
        --             --                 symlink_open = "",
        --             --             },
        --             --             git = {
        --             --                 unstaged = "✗",
        --             --                 staged = "✓",
        --             --                 unmerged = "",
        --             --                 renamed = "➜",
        --             --                 untracked = "★",
        --             --                 deleted = "",
        --             --                 ignored = "◌",
        --             --             },
        --             --         },
        --             --     },
        --             -- },
        --             -- filters = {
        --             --     dotfiles = false,
        --             --     custom = { "^.git$", "^node_modules$", "^.cache$" },
        --             -- },
        --             -- actions = {
        --             --     open_file = {
        --             --         quit_on_open = true,
        --             --     },
        --             -- },
        --             -- git = {
        --             --     ignore = false,
        --             -- },
        --         })
        --     end,
        -- },
        -- --: }}} Nvim-Tree
        -- --: {{{ Copilot
        -- {
        --     "github/copilot.vim",
        --     lazy = false,
        --     config = function()
        --         -- vim.keymap.set('i', '<C-y>', 'copilot#Accept("\\<CR>")', {
        --         --     expr = true,
        --         --     replace_keycodes = false
        --         -- })
        --
        --         -- vim.g.copilot_no_tab_map = true
        --         -- -- vim.keymap.set('i', '<Tab>', '<Nop>', { silent = true })
        --         -- vim.api.nvim_set_keymap("i", "<C-y>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
        --     end,
        -- },
        -- --: }}} Copilot
        --: {{{ CoC
        {
            "neoclide/coc.nvim",
            config = function()
                vim.opt.updatetime = 1600
                local keyset = vim.keymap.set

                vim.g.coc_global_extensions = {
                    'coc-json',
                    'coc-pyright',
                    -- 'coc-clangd',
                }

                -- Autocomplete
                function _G.check_back_space()
                    local col = vim.fn.col('.') - 1
                    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
                end

                -- Use Tab for trigger completion with characters ahead and navigate
                -- NOTE: There's always a completion item selected by default, you may want to enable
                -- no select by setting `"suggest.noselect": true` in your configuration file
                -- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
                -- other plugins before putting this into your config
                local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
                keyset("i", "<TAB>",
                    'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
                keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

                -- Make <CR> to accept selected completion item or notify coc.nvim to format
                -- <C-g>u breaks current undo, please make your own choice
                keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
                    opts)

                -- Use <c-j> to trigger snippets
                keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
                -- Use <c-space> to trigger completion
                keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

                -- Use `[g` and `]g` to navigate diagnostics
                -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
                keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
                keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

                -- GoTo code navigation
                keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
                keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
                keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
                keyset("n", "gr", "<Plug>(coc-references)", { silent = true })

                -- Use K to show documentation in preview window
                function _G.show_docs()
                    local cw = vim.fn.expand('<cword>')
                    if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
                        vim.api.nvim_command('h ' .. cw)
                    elseif vim.api.nvim_eval('coc#rpc#ready()') then
                        vim.fn.CocActionAsync('doHover')
                    else
                        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
                    end
                end

                keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true })


                -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
                vim.api.nvim_create_augroup("CocGroup", {})
                vim.api.nvim_create_autocmd("CursorHold", {
                    group = "CocGroup",
                    command = "silent call CocActionAsync('highlight')",
                    desc = "Highlight symbol under cursor on CursorHold"
                })


                -- Symbol renaming
                keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })


                -- Formatting selected code
                keyset("x", "<leader>f", "<Plug>(coc-format-selected)", { silent = true })
                keyset("n", "<leader>f", "<Plug>(coc-format-selected)", { silent = true })


                -- Setup formatexpr specified filetype(s)
                vim.api.nvim_create_autocmd("FileType", {
                    group = "CocGroup",
                    pattern = "typescript,json",
                    command = "setl formatexpr=CocAction('formatSelected')",
                    desc = "Setup formatexpr specified filetype(s)."
                })

                -- Update signature help on jump placeholder
                vim.api.nvim_create_autocmd("User", {
                    group = "CocGroup",
                    pattern = "CocJumpPlaceholder",
                    command = "call CocActionAsync('showSignatureHelp')",
                    desc = "Update signature help on jump placeholder"
                })

                -- Apply codeAction to the selected region
                -- Example: `<leader>aap` for current paragraph
                local opts = { silent = true, nowait = true }
                keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
                keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

                -- Remap keys for apply code actions at the cursor position.
                keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
                -- Remap keys for apply source code actions for current file.
                keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
                -- Apply the most preferred quickfix action on the current line.
                keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

                -- Remap keys for apply refactor code actions.
                keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
                keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
                keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

                -- Run the Code Lens actions on the current line
                keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)


                -- Map function and class text objects
                -- NOTE: Requires 'textDocument.documentSymbol' support from the language server
                keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
                keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
                keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
                keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
                keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
                keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
                keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
                keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)


                -- Remap <C-f> and <C-b> to scroll float windows/popups
                ---@diagnostic disable-next-line: redefined-local
                local opts = { silent = true, nowait = true, expr = true }
                keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
                keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
                keyset("i", "<C-f>",
                    'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
                keyset("i", "<C-b>",
                    'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
                keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
                keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)


                -- Use CTRL-S for selections ranges
                -- Requires 'textDocument/selectionRange' support of language server
                keyset("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true })
                keyset("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })


                -- Add `:Format` command to format current buffer
                vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

                -- " Add `:Fold` command to fold current buffer
                vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = '?' })

                -- Add `:OR` command for organize imports of the current buffer
                vim.api.nvim_create_user_command("OR",
                    "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

                -- Add (Neo)Vim's native statusline support
                -- NOTE: Please see `:h coc-status` for integrations with external plugins that
                -- provide custom statusline: lightline.vim, vim-airline
                vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

                -- Mappings for CoCList
                -- code actions and coc stuff
                ---@diagnostic disable-next-line: redefined-local
                local opts = { silent = true, nowait = true }
                -- Show all diagnostics
                keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
                -- Manage extensions
                keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
                -- Show commands
                keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
                -- Find symbol of current document
                keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
                -- Search workspace symbols
                keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
                -- Do default action for next item
                keyset("n", "<space>j", ":<C-u>CocNext<cr>", opts)
                -- Do default action for previous item
                keyset("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
                -- Resume latest coc list
                keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)


                vim.cmd [[ highlight CocInlayHint guifg=gray ]]
            end,
        },
        --: }}} CoC
        -- --: {{{ Mini Indent Scope
        -- {
        --     'echasnovski/mini.indentscope',
        --     version = '*',
        --     config = function()
        --         require('mini.indentscope').setup({
        --             symbol = "┃", --"│",
        --         })
        --         vim.cmd([[highlight! link MiniIndentscopeSymbol LineNr]])
        --         -- vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = hslToHex(45, 100, 15) })
        --     end,
        -- },
        -- --: }}} Mini Indent Scope
        -- --: {{{ C++ Modern
        -- {
        --     "bfrg/vim-cpp-modern",
        --     config = function()
        --         vim.cmd([[let g:cpp_attributes_highlight = 1]])
        --         vim.cmd([[let g:cpp_member_highlight = 1]])
        --     end,
        -- },
        -- --: }}} C++ Modern
        --: {{{ Lualine
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = function()
                local lualine = require('lualine')

                -- Color table for highlights
                -- stylua: ignore
                local colors = {
                    bg       = 'NONE', -- '#202328',
                    fg       = '#bbc2cf',
                    yellow   = '#ECBE7B',
                    cyan     = '#008080',
                    darkblue = '#081633',
                    green    = '#98be65',
                    orange   = '#FF8800',
                    violet   = '#a9a1e1',
                    magenta  = '#c678dd',
                    blue     = '#51afef',
                    red      = '#ec5f67',
                }

                local conditions = {
                    buffer_not_empty = function()
                        return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
                    end,
                    hide_in_width = function()
                        return vim.fn.winwidth(0) > 80
                    end,
                    check_git_workspace = function()
                        local filepath = vim.fn.expand('%:p:h')
                        local gitdir = vim.fn.finddir('.git', filepath .. ';')
                        return gitdir and #gitdir > 0 and #gitdir < #filepath
                    end,
                }

                -- Config
                local config = {
                    options = {
                        globalstatus = true,
                        -- Disable sections and component separators
                        component_separators = '',
                        section_separators = '',
                        theme = {
                            -- We are going to use lualine_c an lualine_x as left and
                            -- right section. Both are highlighted by c theme .  So we
                            -- are just setting default looks o statusline
                            normal = { c = { fg = colors.fg, bg = colors.bg } },
                            inactive = { c = { fg = colors.fg, bg = colors.bg } },
                        },
                    },
                    sections = {
                        -- these are to remove the defaults
                        lualine_a = {},
                        lualine_b = {},
                        lualine_y = {},
                        lualine_z = {},
                        -- These will be filled later
                        lualine_c = {},
                        lualine_x = {},
                    },
                    inactive_sections = {
                        -- these are to remove the defaults
                        lualine_a = {},
                        lualine_b = {},
                        lualine_y = {},
                        lualine_z = {},
                        lualine_c = {},
                        lualine_x = {},
                    },
                }

                -- Inserts a component in lualine_c at left section
                local function ins_left(component)
                    table.insert(config.sections.lualine_c, component)
                end

                -- Inserts a component in lualine_x at right section
                local function ins_right(component)
                    table.insert(config.sections.lualine_x, component)
                end

                ins_left {
                    function()
                        return '▊'
                    end,
                    color = { fg = colors.blue },      -- Sets highlighting of component
                    padding = { left = 0, right = 1 }, -- We don't need space before this
                }

                ins_left {
                    -- mode component
                    function()
                        return ''
                    end,
                    color = function()
                        -- auto change color according to neovims mode
                        local mode_color = {
                            n = colors.red,
                            i = colors.green,
                            v = colors.blue,
                            ['␖'] = colors.blue,
                            V = colors.blue,
                            c = colors.magenta,
                            no = colors.red,
                            s = colors.orange,
                            S = colors.orange,
                            ['␓'] = colors.orange,
                            ic = colors.yellow,
                            R = colors.violet,
                            Rv = colors.violet,
                            cv = colors.red,
                            ce = colors.red,
                            r = colors.cyan,
                            rm = colors.cyan,
                            ['r?'] = colors.cyan,
                            ['!'] = colors.red,
                            t = colors.red,
                        }
                        return { fg = mode_color[vim.fn.mode()] }
                    end,
                    padding = { right = 1 },
                }

                -- ins_left {
                --     -- filesize component
                --     'filesize',
                --     icon = '𝌰',
                --     cond = conditions.buffer_not_empty,
                -- }

                ins_left { --a4paper file
                    'filename',
                    path = 1,
                    cond = conditions.buffer_not_empty,
                    -- icon = '⛕',
                    color = { fg = colors.magenta, gui = 'bold' },
                }

                ins_left {
                    'location',
                    -- icon = '⏚',
                    color = { fg = colors.orange, gui = '' },
                }

                ins_left {
                    'progress',
                    -- icon = '',
                    color = { fg = colors.fg, gui = 'bold' }
                }

                -- ins_left {
                --     'diagnostics',
                --     sources = { 'nvim_diagnostic' },
                --     symbols = { error = ' ', warn = ' ', info = ' ' },
                --     diagnostics_color = {
                --         error = { fg = colors.red },
                --         warn = { fg = colors.yellow },
                --         info = { fg = colors.cyan },
                --     },
                -- }

                -- Insert mid section. You can make any number of sections in neovim :)
                -- for lualine it's any number greater then 2
                -- ins_left {
                --     function()
                --         return '%='
                --     end,
                -- }

                -- ins_left {
                --     -- Lsp server name .
                --     function()
                --         local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
                --         local clients = vim.lsp.get_clients()
                --         if next(clients) == nil then
                --             return '⟳'
                --         end
                --         for _, client in ipairs(clients) do
                --             local filetypes = client.config.filetypes
                --             if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                --                 return client.name -- '֎' -- client.name
                --             end
                --         end
                --         return '…'
                --     end,
                --     icon = '',
                --     color = { fg = '#a0a0a0' }, --, gui = 'bold' },
                -- }

                ins_left {
                    'aerial',
                }

                local function get_venv(variable)
                    local venv = os.getenv(variable)
                    if venv ~= nil and string.find(venv, "/") then
                        local orig_venv = venv
                        for w in orig_venv:gmatch("([^/]+)") do
                            venv = w
                        end
                        venv = string.format("%s", venv)
                    end
                    return venv
                end

                -- Add components to right sections
                ins_right {
                    'searchcount',
                    icon = '⛁', --
                }

                ins_right {
                    'selectioncount',
                    icon = '⧮',
                }

                ins_right {
                    function()
                        local venv = get_venv("CONDA_DEFAULT_ENV") or get_venv("VIRTUAL_ENV") or "NO ENV"
                        return venv .. ')'
                    end,
                    --cond = function() return vim.bo.filetype == "python" end,
                    icon = '(',
                    color = { fg = colors.blue, gui = '' },
                }

                ins_right {
                    'branch',
                    icon = '',
                    color = { fg = colors.violet, gui = 'bold' },
                }

                ins_right {
                    'diff',
                    -- Is it me or the symbol for modified us really weird
                    symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
                    diff_color = {
                        added = { fg = colors.green },
                        modified = { fg = colors.orange },
                        removed = { fg = colors.red },
                    },
                    -- cond = conditions.hide_in_width,
                }

                ins_right {
                    'fileformat',
                    --fmt = string.upper,
                    -- icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
                    color = { fg = colors.green, gui = 'bold' },
                }

                ins_right {
                    'encoding', -- option component same as &encoding in viml
                    --fmt = string.upper, -- I'm not sure why it's upper case either ;)
                    cond = conditions.hide_in_width,
                    color = { fg = colors.green, gui = 'bold' },
                }

                local utils = require 'lualine.utils.utils'
                local devicons = require 'nvim-web-devicons'
                ins_right {
                    'filetype',
                    -- icon_only = true,
                    color = function()
                        local _, icon_highlight_group = devicons.get_icon(vim.fn.expand('%:t'))
                        local fg = utils.extract_highlight_colors(icon_highlight_group, 'fg')
                        return { fg = fg, gui = 'bold' }
                    end,
                }

                ins_right {
                    function()
                        --if vim.opt.columns:get() < 110 or vim.opt.lines:get() < 25 then return "" end
                        local time = tostring(os.date()):sub(12, 16)
                        if os.time() % 2 == 1 then time = time:gsub(":", " ") end
                        return time
                    end,
                    -- clock icon
                    icon = ' ', --'',
                    color = { fg = colors.cyan, gui = NONE },
                }

                ins_right {
                    function()
                        return '▊'
                    end,
                    color = { fg = colors.blue },
                    padding = { left = 1 },
                }

                lualine.setup(config)
            end,
        },
        --: }}} Lualine
        -- --: {{{ LSP Config
        -- {
        --     "neovim/nvim-lspconfig",
        --     lazy = false,
        --     config = function()
        --         -- local on_attach = function(client, bufnr)
        --         --     if client.server_capabilities.documentSymbolProvider then
        --         --         require 'nvim-navic'.attach(client, bufnr)
        --         --     end
        --         -- end
        --         --
        --         -- require 'lspconfig'.pyright.setup {
        --         --     on_attach = on_attach,
        --         -- }
        --         --
        --         -- require 'lspconfig'.lua_ls.setup {
        --         --     on_attach = on_attach,
        --         --     settings = {
        --         --         Lua = {
        --         --             diagnostics = {
        --         --                 globals = { 'vim', 'NONE' },
        --         --             },
        --         --         },
        --         --     },
        --         -- }
        --
        --         -- require 'lspconfig'.clangd.setup {
        --         --     -- on_attach = on_attach,
        --         -- }
        --         -- vim.cmd([[nnoremap <leader>hx <cmd>ClangdShowSymbolInfo<CR>]])
        --         -- vim.cmd([[nnoremap <leader>hh <cmd>ClangdSwitchSourceHeader<CR>]])
        --
        --         -- require 'lspconfig'.fish_lsp.setup {}
        --     end,
        -- },
        -- --: }}} LSP Config
        --: {{{ Git Signs
        {
            'lewis6991/gitsigns.nvim',
            event = "BufReadPre",
            -- config = function()
            --     require 'gitsigns'.setup()
            -- end,
        },
        --: }}} Git Signs
        -- --: {{{ Toggle Term
        -- {
        --     'akinsho/toggleterm.nvim',
        --     version = "*",
        --     config = function()
        --         require 'toggleterm'.setup({
        --             shell = 'fish',
        --         })
        --
        --         vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<CR>', { silent = true })
        --
        --         vim.api.nvim_create_user_command('T', function(opts)
        --             require 'toggleterm'.exec(opts.args)
        --         end, { nargs = 1, desc = 'Single TermExec' })
        --
        --         vim.api.nvim_create_user_command('Tc', function()
        --             require 'toggleterm'.exec("function fish_prompt;echo -e '\\033[32m~ \\033[0m';end;clear")
        --         end, { desc = 'Clean prompt' })
        --     end,
        -- },
        -- --: }}} Toggle Term
        -- --: {{{ Vim Fugitive
        -- {
        --     'tpope/vim-fugitive',
        -- },
        -- --: }}} Vim Fugitive
        -- --: {{{ fish
        -- {
        --     'nickeb96/fish.vim',
        --     lazy = true,
        -- },
        -- --: }}} fish
        -- --: {{{ Avante
        -- {
        --     "yetone/avante.nvim",
        --     -- build from source: `make BUILD_FROM_SOURCE=true` ⚠️ must add this setting! ! !
        --     build = "make",
        --     event = "VeryLazy",
        --     version = false, -- Never set this value to "*"! Never!
        --     config = function()
        --         local xai_provider = function(model)
        --             return {
        --                 __inherited_from = "openai",
        --                 endpoint = "https://api.x.ai/v1",
        --                 api_key_name = "XAI_API_KEY",
        --                 timeout = 30000, -- Timeout in milliseconds
        --                 extra_request_body = { temperature = 0.75, max_tokens = 64000 },
        --                 model = model,
        --             }
        --         end
        --
        --         require("avante").setup({
        --             instructions_file = "avante.md", -- this file can contain specific instructions for your project
        --             provider = "xai-code",
        --             providers = {
        --                 ["xai-code"] = xai_provider "grok-code-fast-1",
        --                 ["xai-4-fr"] = xai_provider "grok-4-fast-reasoning",
        --                 ["xai-4-fnr"] = xai_provider "grok-4-fast-non-reasoning",
        --                 ["xai-4"] = xai_provider "grok-4-0709",
        --             },
        --             selection = { hint_display = "none" },
        --             mappings = {
        --                 ask = "<leader>kj",
        --                 edit = "<leader>kk",
        --                 submit = { insert = "<C-k>" },
        --                 select_model = "<leader>kl",
        --             },
        --             -- windows = {
        --             --     -- ask = { floating = true },
        --             -- },
        --             -- auto_suggestions_provider = "xai-code",
        --             -- behaviour = {
        --             --     auto_suggestions = true,
        --             -- },
        --             -- suggestion = { debounce = 600, throttle = 900 },
        --         })
        --     end,
        --     dependencies = {
        --         "nvim-lua/plenary.nvim",
        --         "MunifTanjim/nui.nvim",
        --         --- The below dependencies are optional,
        --         "nvim-mini/mini.pick",           -- for file_selector provider mini.pick
        --         "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        --         "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
        --         "ibhagwan/fzf-lua",              -- for file_selector provider fzf
        --         "stevearc/dressing.nvim",        -- for input provider dressing
        --         -- "folke/snacks.nvim",             -- for input provider snacks
        --         "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
        --         "zbirenbaum/copilot.lua",        -- for providers='copilot'
        --         {
        --             -- support for image pasting
        --             "HakonHarnes/img-clip.nvim",
        --             event = "VeryLazy",
        --             opts = {
        --                 -- recommended settings
        --                 default = {
        --                     embed_image_as_base64 = false,
        --                     prompt_for_file_name = false,
        --                     drag_and_drop = {
        --                         insert_mode = true,
        --                     },
        --                     -- required for Windows users
        --                     use_absolute_path = true,
        --                 },
        --             },
        --         },
        --         {
        --             -- Make sure to set this up properly if you have lazy=true
        --             'MeanderingProgrammer/render-markdown.nvim',
        --             opts = {
        --                 file_types = { "markdown", "Avante" },
        --             },
        --             ft = { "markdown", "Avante" },
        --         },
        --     },
        -- },
        -- --: }}} Avante
        --: {{{ windsurf/codeium
        {
            'Exafunction/windsurf.vim',
        },
        --: }}} windsurf/codeium
        --: {{{ Snacks
        {
            "folke/snacks.nvim",
            priority = 1000,
            lazy = false,
            opts = {
                bigfile = { enabled = true },
                dashboard = {
                    enabled = true,
                    sections = {
                        { section = "header" },
                        { section = "keys",  gap = 1, padding = 2 },
                        {
                            icon = " ",
                            title = "Status",
                            section = "terminal",
                            enabled = function()
                                return Snacks.git.get_root() ~= nil
                            end,
                            cmd = "git status --short --branch --renames",
                            height = 5,
                            ttl = 5 * 60,
                            indent = 2,
                        },
                        {
                            icon = " ",
                            title = "Summary",
                            section = "terminal",
                            enabled = function()
                                return Snacks.git.get_root() ~= nil
                            end,
                            cmd = "git --no-pager diff --stat -B -M -C",
                            height = 5,
                            ttl = 5 * 60,
                            indent = 2,
                        },
                        { section = "startup" },
                    },
                },
                explorer = { enabled = true },
                indent = {
                    enabled = true,
                    indent = {
                        only_scope = true,
                        only_current = true,
                    },
                },
                input = {
                    enabled = true,
                    icon = " ",
                    icon_hl = "SnacksInputIcon",
                    icon_pos = "left",
                    prompt_pos = "title",
                    win = { style = "input" },
                    expand = true,
                },
                picker = {
                    enabled = true,
                    sources = {
                        files = {
                            hidden = true,
                            no_ignore = true,
                        },
                    },
                },
                notifier = { enabled = true },
                quickfile = { enabled = true },
                scope = { enabled = true },
                scroll = { enabled = true },
                statuscolumn = {
                    enabled = true,
                    folds = {
                        open = true,
                        git_hl = true,
                    },
                },
                words = { enabled = true },
                lazygit = { enabled = true },
            },
            keys = {
                -- Top Pickers & Explorer
                { "<leader><space>", function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
                { "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
                { "<leader>/",       function() Snacks.picker.grep() end,                                    desc = "Grep" },
                { "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History" },
                { "<leader>n",       function() Snacks.picker.notifications() end,                           desc = "Notification History" },
                { "<leader>e",       function() Snacks.explorer() end,                                       desc = "File Explorer" },
                -- find
                { "<leader>fb",      function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
                { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
                { "<leader>ff",      function() Snacks.picker.files() end,                                   desc = "Find Files" },
                { "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
                { "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "Projects" },
                { "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent" },
                -- git
                { "<leader>gb",      function() Snacks.picker.git_branches() end,                            desc = "Git Branches" },
                { "<leader>gl",      function() Snacks.picker.git_log() end,                                 desc = "Git Log" },
                { "<leader>gL",      function() Snacks.picker.git_log_line() end,                            desc = "Git Log Line" },
                { "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "Git Status" },
                { "<leader>gS",      function() Snacks.picker.git_stash() end,                               desc = "Git Stash" },
                { "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
                { "<leader>gf",      function() Snacks.picker.git_log_file() end,                            desc = "Git Log File" },
                -- Grep
                { "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
                { "<leader>sB",      function() Snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
                { "<leader>sg",      function() Snacks.picker.grep() end,                                    desc = "Grep" },
                { "<leader>sw",      function() Snacks.picker.grep_word() end,                               desc = "Visual selection or word", mode = { "n", "x" } },
                -- search
                { '<leader>s"',      function() Snacks.picker.registers() end,                               desc = "Registers" },
                { '<leader>s/',      function() Snacks.picker.search_history() end,                          desc = "Search History" },
                { "<leader>sa",      function() Snacks.picker.autocmds() end,                                desc = "Autocmds" },
                { "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
                { "<leader>sc",      function() Snacks.picker.command_history() end,                         desc = "Command History" },
                { "<leader>sC",      function() Snacks.picker.commands() end,                                desc = "Commands" },
                { "<leader>sd",      function() Snacks.picker.diagnostics() end,                             desc = "Diagnostics" },
                { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                      desc = "Buffer Diagnostics" },
                { "<leader>sh",      function() Snacks.picker.help() end,                                    desc = "Help Pages" },
                { "<leader>sH",      function() Snacks.picker.highlights() end,                              desc = "Highlights" },
                { "<leader>si",      function() Snacks.picker.icons() end,                                   desc = "Icons" },
                { "<leader>sj",      function() Snacks.picker.jumps() end,                                   desc = "Jumps" },
                { "<leader>sk",      function() Snacks.picker.keymaps() end,                                 desc = "Keymaps" },
                { "<leader>sl",      function() Snacks.picker.loclist() end,                                 desc = "Location List" },
                { "<leader>sm",      function() Snacks.picker.marks() end,                                   desc = "Marks" },
                { "<leader>sM",      function() Snacks.picker.man() end,                                     desc = "Man Pages" },
                { "<leader>sp",      function() Snacks.picker.lazy() end,                                    desc = "Search for Plugin Spec" },
                { "<leader>sq",      function() Snacks.picker.qflist() end,                                  desc = "Quickfix List" },
                { "<leader>sR",      function() Snacks.picker.resume() end,                                  desc = "Resume" },
                { "<leader>su",      function() Snacks.picker.undo() end,                                    desc = "Undo History" },
                { "<leader>uC",      function() Snacks.picker.colorschemes() end,                            desc = "Colorschemes" },
                -- LSP
                { "gd",              function() Snacks.picker.lsp_definitions() end,                         desc = "Goto Definition" },
                { "gD",              function() Snacks.picker.lsp_declarations() end,                        desc = "Goto Declaration" },
                { "gr",              function() Snacks.picker.lsp_references() end,                          nowait = true,                     desc = "References" },
                { "gI",              function() Snacks.picker.lsp_implementations() end,                     desc = "Goto Implementation" },
                { "gy",              function() Snacks.picker.lsp_type_definitions() end,                    desc = "Goto T[y]pe Definition" },
                { "gai",             function() Snacks.picker.lsp_incoming_calls() end,                      desc = "C[a]lls Incoming" },
                { "gao",             function() Snacks.picker.lsp_outgoing_calls() end,                      desc = "C[a]lls Outgoing" },
                { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,                             desc = "LSP Symbols" },
                { "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end,                   desc = "LSP Workspace Symbols" },
                -- Kustom
                {
                    "<leader>ka",
                    function()
                        require "aerial".snacks_picker {
                            layout = {
                                preset = "dropdown",
                                -- preview = false,
                            }
                        }
                    end,
                    desc = "Aerial Buffer Symbols"
                },
            },
        },
        --: }}} Snacks
        --: {{{ Noice
        {
            "folke/noice.nvim",
            event = "VeryLazy",
            opts = {
                cmdline = {
                    enabled = true,
                    view = "cmdline_popup",
                    opts = {
                        position = {
                            row = 0,
                            col = "50%",
                        },
                        size = {
                            width = "50%",
                        },
                    },
                },
                messages = {
                    enabled = true,
                    view = "notify",
                    view_error = "notify",
                    view_warn = "notify",
                    view_history = "messages",
                    view_search = "virtualtext",
                },
                routes = {
                    {
                        filter = {
                            event = "msg_show",
                            any = {
                                { find = "%d+L, %d+B" },
                                { find = "; after #%d+" },
                                { find = "; before #%d+" },
                            },
                        },
                        view = "mini",
                    },
                },
                presets = {
                    bottom_search = false,
                    command_palette = true,
                    long_message_to_split = true,
                    inc_rename = false,
                    lsp_doc_border = false,
                },
            },
            dependencies = {
                "MunifTanjim/nui.nvim", -- Requerido por noice
                "rcarriga/nvim-notify", -- Para notificaciones (opcional pero recomendado)
            },
        },
        --: }}} Noice
        --: {{{ Specs end
        { import = 'plugins' },
    },
    --: }}} Specs end
    --: {{{ Additional
    --install = { colorscheme = { "habamax" } },
    checker = { enabled = false },
    --: }}} Additional
})

--: {{{ Status Sign Fold Nr
-- ; (function()
--     local columns = vim.api.nvim_get_option('columns')
--     if columns < 135 then
--         vim.o.foldcolumn = '4'
--         vim.o.signcolumn = 'yes:6'
--         vim.o.numberwidth = 5
--         vim.o.statuscolumn = '%l %C %s '
--     elseif columns < 184 then
--         vim.o.foldcolumn = '6'
--         vim.o.signcolumn = 'yes:8'
--         vim.o.numberwidth = 5
--         vim.o.statuscolumn = '      %l %C %s         '
--     else
--         vim.o.foldcolumn = '6'
--         vim.o.signcolumn = 'yes:8'
--         vim.o.numberwidth = 5
--         vim.o.statuscolumn = '         %l %C %s            '
--     end;
-- end)()

vim.o.foldcolumn = '3'
vim.o.signcolumn = 'yes:3'
vim.o.numberwidth = 5

vim.o.foldenable = true
vim.o.foldmethod = 'expr'

vim.o.laststatus = 3

vim.o.number = false
vim.o.backspace = 'indent,eol,start'

vim.opt.fillchars:append({ vert = '▏', eob = " " })

vim.o.ruler = false
vim.o.showcmd = false
--: }}} Status Sign Fold Nr

--: {{{ Configuración básica
vim.o.compatible = false
vim.o.encoding = 'utf-8'

--: {{{ backup, swap y undo
; (function()
    local home = os.getenv('HOME')
    if not home or home == '' then
        error('HOME is not set')
    end
    vim.o.backupdir = home .. '/.config/nvim/dot/backup/'
    vim.o.directory = home .. '/.config/nvim/dot/swap/'
    vim.o.undodir = home .. '/.config/nvim/dot/undo/'
end)()
vim.o.backup = true
vim.o.swapfile = true
vim.o.undofile = true
--: }}} backup, swap y undo

vim.o.mouse = 'a'

vim.o.wildignorecase = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true

-- expresión regular y coincidencia
vim.o.magic = true
vim.o.showmatch = true

-- tabulación e indentación
vim.o.expandtab = true
vim.o.smarttab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.wrap = true

vim.keymap.set('n', 'U', ':redo<CR>')
--: }}} Configuración básica

-- --: {{{ Keymaps
-- local copts = { noremap = true, silent = true }
-- local nopts = { noremap = false, silent = true }
-- vim.keymap.set('i', '<C-g>', '<Esc>:w<CR>', nopts)
-- vim.keymap.set('n', '<C-g>', ':w<CR>', nopts)
-- vim.keymap.set('n', '<C-k>', ':bprevious<CR>', copts)
-- vim.keymap.set('n', '<C-l>', ':bnext<CR>', copts)
-- --vim.keymap.set('n', '<C-j>', ':Bwipeout<CR>', copts)
-- vim.keymap.set('n', '<C-j>', ':silent! bp<bar>vsp<bar>silent! bn<bar>bd<CR>', copts)
--
-- vim.keymap.set('n', '<C-p>', function() Snacks.picker.files() end, copts)
--
-- if vim.loop.os_uname().sysname == 'Darwin' then
--     vim.keymap.set('i', '©', '<Esc>:w!<CR>')
--     vim.keymap.set('n', '©', ':w!<CR>')
--
--     vim.keymap.set('n', '∑', '<C-w>')
--     vim.keymap.set('i', '∑', '<C-w>')
--     vim.keymap.set('c', '∑', '<C-w>')
--
--     vim.keymap.set('n', '˚', ':bprevious<CR>')
--     vim.keymap.set('n', '¬', ':bnext<CR>')
--     vim.keymap.set('n', '∆', ':bp|bd #<CR>')
--
--     vim.keymap.set('n', 'π', "<leader>ff")
-- end
-- --: }}} Keymaps

--: {{{ Colors
vim.o.termguicolors = true
--vim.o.t_Co = 256
--vim.o.t_8f = "\27[38;2;%lu;%lu;%lum"
--vim.o.t_8b = "\27[48;2;%lu;%lu;%lum"
--: }}} Colors

vim.g.lazyvim_check_order = false

-- vim: set ts=4 sw=4 sts=4 et ft=lua fdm=marker:

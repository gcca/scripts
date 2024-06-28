vim.fn.sign_define("DiagnosticSignError",
  { text = " ", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn",
  { text = " ", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo",
  { text = " ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint",
  { text = "󰌵", texthl = "DiagnosticSignHint" })

vim.cmd([[nnoremap <leader>nt :Neotree reveal<cr>:wincmd p<cr>]])

require("neo-tree").setup({
  close_if_last_window = true,
  default_component_configs = {
    indent = {
      indent_size = 1,
      indent_marker = " ",
    },
    modified = {
      symbol = "✎",
      highlight = "NeoTreeModified",
    },
    git_status = {
      symbols = {
        -- Change type
        added     = "✚",
        modified  = "",
        deleted   = "✖",
        renamed   = "󰁕",
        -- Status type
        untracked = "",
        ignored   = "",
        unstaged  = "󰄱",
        staged    = "",
        conflict  = "",
      }
    },
  },
  window = {
    width = 27,
    side = "left",
    focus = false,
  },
})

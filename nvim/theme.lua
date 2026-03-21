return {
  { "EdenEast/nightfox.nvim",     lazy = true },
  { "ellisonleao/gruvbox.nvim",   lazy = true },
  { "rebelot/kanagawa.nvim",      lazy = true },
  { "gthelding/monokai-pro.nvim", lazy = true },
  { "rose-pine/neovim",           lazy = true },
  { "catppuccin/nvim",            lazy = true },
  { "neanias/everforest-nvim",    lazy = true },
  { "ribru17/bamboo.nvim",        lazy = true },
  { "tahayvr/matteblack.nvim",    lazy = true },
  { "folke/tokyonight.nvim",      lazy = true },
  { "kepano/flexoki-neovim",      lazy = true },
  { "Shatur/neovim-ayu",          lazy = true },
  { "rose-pine/neovim",           lazy = true, name = "rose-pine" },
  (function()
    local model   = vim.trim(vim.fn.system("sysctl -n hw.model"))

    local current = os.date('*t')
    local hour    = current.hour
    local min     = current.min
    local is_dark = (hour > 18 or (hour == 18 and min >= 30)) or (hour < 6 or (hour == 6 and min < 30))

    if model == "Mac14,5" then
      return {
        "rose-pine/neovim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
          vim.o.background = is_dark and 'dark' or 'light'
          require 'rose-pine'.setup({
            variant = 'dawn',
            dark_variant = 'moon',
          })
          vim.cmd.colorscheme("rose-pine")
        end,
      }
    elseif model == "Mac16,9" then
      return {
        "rose-pine/neovim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
          vim.o.background = is_dark and 'dark' or 'light'
          require 'rose-pine'.setup({
            variant = 'dawn',
            dark_variant = 'moon',
          })
          vim.cmd.colorscheme("rose-pine")
        end,
      }
    else
      return {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
          vim.cmd.colorscheme("nightfox")
          vim.notify(
            "Unrecognized Mac model: " .. (model ~= "" and model or "unknown") .. "\nFalling back to nightfox",
            vim.log.levels.WARN,
            { title = "Theme Configuration" }
          )
        end,
      }
    end
  end)()
}

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
  (function()
    local model   = vim.trim(vim.fn.system("sysctl -n hw.model"))

    local current = os.date('*t')
    local hour    = current.hour
    local min     = current.min
    local is_dark = (hour > 18 or (hour == 18 and min >= 30)) or (hour < 6 or (hour == 6 and min < 20))

    if model == "Mac14,5" then
      return {
        "rose-pine/neovim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
          if is_dark then
            vim.o.background ='dark'
            require 'rose-pine'.setup({ variant = 'main' })
            vim.cmd.colorscheme("rose-pine-main")
          else
            vim.o.background = 'light'
            require 'rose-pine'.setup({ variant = 'moon' })
            vim.cmd.colorscheme("rose-pine-moon")
          end
        end,
      }
    elseif model == "Mac16,9" then
      return {
        "gthelding/monokai-pro.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
          if is_dark then
            vim.o.background ='dark'
            vim.cmd.colorscheme("tokyonight-night")
          else
            vim.o.background = 'light'
            vim.cmd.colorscheme("monokai-pro-octagon")
          end
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

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
    local cache_file = vim.fn.stdpath("cache") .. "/hw_model"
    local model
    local stat = vim.uv.fs_stat(cache_file)
    if stat then
      local fd = vim.uv.fs_open(cache_file, "r", 438)
      if fd then
        local data = vim.uv.fs_read(fd, stat.size, 0)
        vim.uv.fs_close(fd)
        model = data and vim.trim(data) or ""
      end
    end
    if not model or model == "" then
      model = vim.trim(vim.fn.system("sysctl -n hw.model"))
      local fd = vim.uv.fs_open(cache_file, "w", 438)
      if fd then
        vim.uv.fs_write(fd, model, 0)
        vim.uv.fs_close(fd)
      end
    end

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
            vim.o.background = 'dark'
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
            vim.o.background = 'dark'
            vim.cmd.colorscheme("monokai-pro-spectrum")
            for _, group in ipairs({ "Normal", "LineNr" }) do
              local hl = vim.api.nvim_get_hl(0, { name = group })
              hl.bg = NONE
              vim.api.nvim_set_hl(0, group, hl)
            end
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

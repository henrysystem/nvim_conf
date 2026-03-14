return {
  {
    -- {
    --   "xiyaowong/transparent.nvim",
    --   config = function()
    --     require("transparent").setup({
    --       extra_groups = { -- table/string: additional groups that should be cleared
    --         "Normal",
    --         "NormalNC",
    --         "Comment",
    --         "Constant",
    --         "Special",
    --         "Identifier",
    --         "Statement",
    --         "PreProc",
    --         "Type",
    --         "Underlined",
    --         "Todo",
    --         "String",
    --         "Function",
    --         "Conditional",
    --         "Repeat",
    --         "Operator",
    --         "Structure",
    --         "LineNr",
    --         "NonText",
    --         "SignColumn",
    --         "CursorLineNr",
    --         "EndOfBuffer",
    --       },
    --       exclude_groups = {}, -- table: groups you don't want to clear
    --     })
    --   end,
    -- },
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      opts = {
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = true, -- disables setting the background color.
        term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
      },
    },
    {
      "Gentleman-Programming/gentleman-kanagawa-blur",
      name = "gentleman-kanagawa-blur",
      priority = 1000,
    },
    {
      "Alan-TheGentleman/oldworld.nvim",
      lazy = false,
      priority = 1000,
      opts = {},
    },
    {
      "rebelot/kanagawa.nvim",
      priority = 1000,
      lazy = true,
      config = function()
        local function apply_transparency()
          local groups = {
            "Normal",
            "NormalNC",
            "NormalFloat",
            "FloatBorder",
            "FloatTitle",
            "SignColumn",
            "EndOfBuffer",
            "WinSeparator",
            "StatusLine",
            "StatusLineNC",
            "TelescopeNormal",
            "TelescopeBorder",
            "SnacksNormal",
            "SnacksPickerNormal",
            "SnacksPickerBorder",
          }
          for _, group in ipairs(groups) do
            pcall(vim.api.nvim_set_hl, 0, group, { bg = "none" })
          end
          pcall(function()
            vim.o.winborder = "rounded"
          end)
          vim.opt.winblend = 18
          vim.opt.pumblend = 18
        end

        require("kanagawa").setup({
          compile = false, -- enable compiling the colorscheme
          undercurl = true, -- enable undercurls
          commentStyle = { italic = true },
          functionStyle = {},
          keywordStyle = { italic = true },
          statementStyle = { bold = true },
          typeStyle = {},
          transparent = true,
          dimInactive = false, -- dim inactive window `:h hl-NormalNC`
          terminalColors = true, -- define vim.g.terminal_color_{0,17}
          colors = { -- add/modify theme and palette colors
            palette = {},
            theme = {
              wave = {},
              lotus = {},
              dragon = {},
              all = {
                ui = {
                  bg_gutter = "none",
                  bg_sidebar = "none",
                  bg_float = "none",
                },
              },
            },
          },
          overrides = function(colors) -- add/modify highlights
            return {
              LineNr = { bg = "none" },
              FloatBorder = { fg = "#8BA8FF", bg = "none" },
              FloatTitle = { fg = "#9AD1FF", bg = "none", bold = true },
              TelescopeBorder = { fg = "#8BA8FF", bg = "none" },
              TelescopeTitle = { fg = colors.palette.dragonAqua, bold = true },
              WhichKeyBorder = { fg = "#8BA8FF", bg = "none" },
              SnacksPickerBorder = { fg = "#8BA8FF", bg = "none" },
              WinSeparator = { fg = "#5B6FA6", bg = "none" },
            }
          end,
          theme = "dragon", -- Load "dragon" theme
          background = { -- map the value of 'background' option to a theme
            dark = "dragon",
            light = "lotus",
          },
        })

        apply_transparency()
        vim.api.nvim_create_autocmd("ColorScheme", {
          callback = apply_transparency,
        })
      end,
    },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "kanagawa",
      },
    },
  },
}

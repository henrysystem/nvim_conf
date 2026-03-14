return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  config = function(_, opts)
    local snacks = require("snacks")
    snacks.setup(opts)

    if snacks.input and snacks.input.enable then
      snacks.input.enable()
    end
    vim.ui.select = snacks.picker.select
  end,
  opts = {
    dashboard = { enabled = true },
    explorer = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    image = { enabled = false },
    picker = {
      enabled = true,
      ui_select = true,
    },
    statuscolumn = { enabled = true },
  },
}

-- Configure Node.js before loading plugins
require("config.nodejs").setup({ silent = true })

local user_bin = vim.fn.expand("~/AppData/Local/bin")
if vim.fn.isdirectory(user_bin) == 1 then
  local sep = ";"
  local path_value = vim.env.PATH or ""
  local has_path = (sep .. path_value .. sep):find(sep .. user_bin .. sep, 1, true) ~= nil
  if not has_path then
    vim.env.PATH = user_bin .. sep .. path_value
  end
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Sistema de hosts (selección manual de máquina)
local hosts = require("config.hosts")
local current_host_key, current_host = hosts.get_current_host()

if not current_host then
  -- No hay host configurado, mostrar selector
  vim.defer_fn(function()
    hosts.select_host(function(key, host)
      current_host_key = key
      current_host = host
      -- Recargar assistant con el nuevo host
      package.loaded["config.assistant"] = nil
      require("config.assistant").setup()
    end)
  end, 100)
else
  -- Host ya configurado, cargar normalmente
  require("config.assistant").setup()
end

-- Guardar host actual en variable global para acceso rápido
vim.g.nvim_host_key = current_host_key
vim.g.nvim_host = current_host

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Desactivar prompt de guardar sesión
vim.opt.sessionoptions:remove("globals")
vim.opt.sessionoptions:remove("buffers")
vim.g.persistent_undo = false

vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0



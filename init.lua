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

-- ============================================
-- VIM - Ocultar secrets (ÚLTIMO INTENTO ROBUSTO)
-- ============================================

-- Crear una función para aplicar la ocultación
local function apply_secret_conceal()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
    
    -- La magia está en \zs: todo lo que está antes de \zs se muestra, 
    -- y todo lo que está después se oculta.
    -- Buscamos KEY=, TOKEN:, etc. y ocultamos todo hasta el final de la palabra (espacio)
    vim.cmd([[
      syntax match VeilSecret "\v(GEMINI_API_KEY|OPENAI_API_KEY|ANTHROPIC_API_KEY|DATABASE_URL|DB_PASSWORD|EMAIL_PASSWORD|GITHUB_TOKEN|API_SECRET)[=:][^\s]+" conceal cchar=*
      highlight link VeilSecret Conceal
    ]])
end

-- Aplicar automáticamente al leer o crear archivos sensibles
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    pattern = { ".env*", "opencode.json", "*credentials*", "*secrets*", "*.secret" },
    callback = function()
        apply_secret_conceal()
    end,
})
-- Toggle (mostrar/ocultar)
vim.keymap.set("n", "<leader>sv", function()
    if vim.opt_local.conceallevel:get() == 0 then
        vim.opt_local.conceallevel = 2
        vim.notify("✓ Secrets ocultos", vim.log.levels.INFO)
    else
        vim.opt_local.conceallevel = 0
        vim.notify("✓ Secrets visibles", vim.log.levels.INFO)
    end
end, { desc = "Toggle secrets visibility" })

vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0



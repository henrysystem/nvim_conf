-- Helper para resolver rutas según el host configurado
-- Uso: local paths = require("config.paths")
--        paths.dynasif()  -> retorna la ruta de dynasif según el host actual

local M = {}

-- Alias de rutas disponibles
M.aliases = {
  d = "base",
  base = "base",
  dynasif = "dynasif",
  trading = "trading",
  respaldos = "respaldos",
  recursos = "recursos",
  proyectos = "proyectos",
}

-- Obtener la configuración del host actual
function M.get_host()
  return vim.g.nvim_host_key, vim.g.nvim_host
end

-- Obtener una ruta por alias
function M.get(alias)
  local _, host = M.get_host()
  if not host then
    vim.notify("No hay host configurado. Ejecuta :SelectHost", vim.log.levels.WARN)
    return nil
  end

  local key = M.aliases[alias] or alias
  local path = host[key]
  
  if not path then
    vim.notify("Alias '" .. alias .. "' no existe en host '" .. (vim.g.nvim_host_key or "unknown") .. "'", vim.log.levels.WARN)
    return nil
  end
  
  return path
end

-- Obtener múltiples paths de una vez
function M.get_multiple(...)
  local result = {}
  for _, alias in ipairs({ ... }) do
    result[alias] = M.get(alias)
  end
  return result
end

-- Resolver una ruta hardcodeada al path correcto del host
-- Ejemplo: "D:/Pintulac/01_PRODUCCION/dynasif" -> según host
function M.resolve(hardcoded_path)
  if not hardcoded_path then
    return nil
  end
  
  -- Mapeo de rutas hardcodeadas a aliases
  local route_map = {
    ["D:/Pintulac/01_PRODUCCION/dynasif"] = "dynasif",
    ["D:/Proyectos/Activos/trading/TradingManager"] = "trading",
    ["D:/Pintulac/06_RESPALDOS/Funcionalidades/Respaldos-Funcionalidades/Respaldos"] = "respaldos",
    ["D:/Recursos"] = "recursos",
    ["D:/Proyectos"] = "proyectos",
    ["D:"] = "base",
    -- Agregar más rutas según sea necesario
  }
  
  local normalized = hardcoded_path:gsub("\\", "/"):gsub("/+$", "")
  
  for old_path, alias in pairs(route_map) do
    local normalized_old = old_path:gsub("\\", "/"):gsub("/+$", "")
    if normalized == normalized_old then
      return M.get(alias)
    end
  end
  
  -- Si no hay mapeo, retornar el path original (para paths no mapeados)
  return hardcoded_path
end

-- Comando vim para seleccionar host manualmente
vim.api.nvim_create_user_command("SelectHost", function()
  require("config.hosts").select_host(function(key, host)
    vim.g.nvim_host_key = key
    vim.g.nvim_host = host
    package.loaded["config.assistant"] = nil
    require("config.assistant").setup()
    vim.notify("Host cambiado a: " .. host.name, vim.log.levels.INFO)
  end)
end, {})

-- Comando para ver el host actual
vim.api.nvim_create_user_command("ShowHost", function()
  local key, host = M.get_host()
  if host then
    vim.notify("Host actual: " .. host.name .. " (" .. key .. ")", vim.log.levels.INFO)
  else
    vim.notify("No hay host configurado", vim.log.levels.WARN)
  end
end, {})

return M

-- Configuración de hosts para múltiples máquinas
-- Lee desde hosts.json para compatibilidad con otras herramientas
-- Para usar: establece la variable de entorno NVIM_HOST=nombre_host
-- O selecciona manualmente al iniciar

local M = {}

-- Cargar hosts desde JSON
local function load_hosts_from_json()
  local config_dir = vim.fn.stdpath("config")
  local json_file = config_dir .. "/hosts.json"
  
  if vim.fn.filereadable(json_file) == 1 then
    local ok, result = pcall(vim.fn.readfile, json_file)
    if ok and result then
      local content = table.concat(result, "\n")
      local ok_decode, data = pcall(vim.json.decode, content)
      if ok_decode and data and data.hosts then
        return data.hosts
      end
    end
  end
  
  -- Fallback: datos hardcodeados si no existe el JSON
  return nil
end

-- Intentar cargar desde JSON, si falla usar defaults
M.hosts = load_hosts_from_json()

-- Si no se pudo cargar desde JSON, usar datos por defecto
if not M.hosts then
  M.hosts = {
    windows_main = {
      name = "Windows Principal",
      paths = {
        base = "D:",
        dynasif = "D:/Pintulac/01_PRODUCCION/dynasif",
        trading = "D:/Proyectos/Activos/trading/TradingManager",
        respaldos = "D:/Pintulac/06_RESPALDOS/Funcionalidades/Respaldos-Funcionalidades/Respaldos",
        recursos = "D:/Recursos",
        proyectos = "D:/Proyectos",
      },
    },
    macbook = {
      name = "MacBook Pro",
      paths = {
        base = "/Users/bengy",
        dynasif = "/Users/bengy/Proyectos/dynasif",
        trading = "/Users/bengy/Trading/TradingManager",
        respaldos = "/Users/bengy/Backups/Respaldos",
        recursos = "/Users/bengy/Recursos",
        proyectos = "/Users/bengy/Proyectos",
      },
    },
  }
end

-- Normalizar estructura (soporta tanto formato JSON como legacy)
-- El formato JSON usa "paths" mientras que el legacy usa keys directas
local function normalize_host(host)
  if not host then
    return nil
  end
  
  -- Si tiene "paths", usarlos directamente
  if host.paths then
    -- Asegurar que favorites y commands existan
    host.favorites = host.favorites or {}
    host.commands = host.commands or {}
    return host
  end
  
  -- Legacy: convertir de formato flat a estructurado
  return {
    name = host.name,
    base = host.base,
    dynasif = host.dynasif,
    trading = host.trading,
    respaldos = host.respaldos,
    recursos = host.recursos,
    proyectos = host.proyectos,
    documents = host.documents,
    favorites = host.favorites or {},
    commands = host.commands or {},
  }
end

-- Obtener el directorio de configuración de nvim
function M.get_config_dir()
  local config_dir = vim.fn.stdpath("config")
  return config_dir
end

-- Archivo donde se guarda el último host seleccionado
function M.get_last_host_file()
  return M.get_config_dir() .. "/last_host.txt"
end

-- Obtener el último host seleccionado
function M.get_last_host()
  local file = M.get_last_host_file()
  if vim.fn.filereadable(file) == 1 then
    local lines = vim.fn.readfile(file)
    if #lines > 0 then
      return lines[1]
    end
  end
  return nil
end

-- Guardar el último host seleccionado
function M.save_last_host(host_key)
  local file = M.get_last_host_file()
  vim.fn.writefile({ host_key }, file)
end

-- Obtener el host actual (优先级: env > saved > prompt)
function M.get_current_host()
  -- 1. Buscar en variable de entorno
  local env_host = os.getenv("NVIM_HOST")
  if env_host and M.hosts[env_host] then
    return env_host, normalize_host(M.hosts[env_host])
  end

  -- 2. Buscar último host guardado
  local last_host = M.get_last_host()
  if last_host and M.hosts[last_host] then
    return last_host, normalize_host(M.hosts[last_host])
  end

  -- 3. Si hay solo un host, usarlo automáticamente
  local host_keys = vim.tbl_keys(M.hosts)
  if #host_keys == 1 then
    local key = host_keys[1]
    M.save_last_host(key)
    return key, normalize_host(M.hosts[key])
  end

  -- 4. Retornar nil para mostrar selector
  return nil, nil
end

-- Obtener una ruta por nombre de alias
function M.get_path(alias)
  local _, host = M.get_current_host()
  if not host then
    return nil
  end
  
  -- Buscar primero en paths (formato JSON)
  if host.paths and host.paths[alias] then
    return host.paths[alias]
  end
  
  -- Luego buscar en keys directas (formato legacy)
  if host[alias] then
    return host[alias]
  end
  
  return nil
end

-- Mostrar selector de hosts
function M.select_host(callback)
  local host_list = {}
  for key, host in pairs(M.hosts) do
    table.insert(host_list, { key = key, name = host.name })
  end

  vim.ui.select(host_list, {
    prompt = "Selecciona tu máquina:",
    format_item = function(item)
      return item.name .. " (" .. item.key .. ")"
    end,
  }, function(choice)
    if choice then
      M.save_last_host(choice.key)
      vim.notify("Host seleccionado: " .. choice.name .. "\nAlias: " .. choice.key, vim.log.levels.INFO)
      if callback then
        callback(choice.key, normalize_host(M.hosts[choice.key]))
      end
    end
  end)
end

-- Obtener favoritos del host actual
function M.get_favorites()
  local _, host = M.get_current_host()
  if host and host.favorites then
    return host.favorites
  end
  return {}
end

-- Obtener comandos del host actual
function M.get_commands()
  local _, host = M.get_current_host()
  if host and host.commands then
    return host.commands
  end
  return {}
end

-- Obtener un favorito por clave
function M.get_favorite(key)
  local favorites = M.get_favorites()
  return favorites[key]
end

-- Obtener configuración completa del host actual
function M.get_all()
  return M.get_current_host()
end

-- Recargar hosts desde JSON
function M.reload()
  M.hosts = load_hosts_from_json()
  if not M.hosts then
    -- Usar fallback si no se pudo cargar
    M.hosts = {
      windows_main = {
        name = "Windows Principal",
        base = "D:",
        dynasif = "D:/Pintulac/01_PRODUCCION/dynasif",
        trading = "D:/Proyectos/Activos/trading/TradingManager",
        respaldos = "D:/Pintulac/06_RESPALDOS/Funcionalidades/Respaldos-Funcionalidades/Respaldos",
      },
    }
  end
end

-- Obtener la ruta del archivo hosts.json
function M.get_hosts_file_path()
  return M.get_config_dir() .. "/hosts.json"
end

-- Editar el archivo hosts.json
function M.edit_hosts_file()
  local json_file = M.get_hosts_file_path()
  -- Si no existe, crearlo con un template
  if vim.fn.filereadable(json_file) == 0 then
    vim.notify("El archivo hosts.json no existe en la config de nvim", vim.log.levels.WARN)
    return
  end
  vim.cmd("edit " .. json_file)
end

-- Comando para recargar hosts
vim.api.nvim_create_user_command("ReloadHosts", function()
  require("config.hosts").reload()
  vim.notify("Hosts recargados", vim.log.levels.INFO)
end, {})

-- Comando para editar hosts.json
vim.api.nvim_create_user_command("EditHosts", function()
  require("config.hosts").edit_hosts_file()
end, {})

return M

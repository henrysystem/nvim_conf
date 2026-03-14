local M = {}

-- Función helper para resolver rutas según el host actual
local function resolve_host_path(default_path)
  local hosts = rawget(_G, "hosts") or (pcall(require, "config.hosts") and require("config.hosts"))
  if not hosts then
    return default_path
  end
  
  local _, host = hosts.get_current_host()
  if not host then
    return default_path
  end
  
  -- Mapeo de rutas por defecto a aliases del host
  local path_map = {
    ["D:/Pintulac/01_PRODUCCION/dynasif"] = "dynasif",
    ["D:/Proyectos/Activos/trading/TradingManager"] = "trading",
    ["D:/Pintulac/06_RESPALDOS/Funcionalidades/Respaldos-Funcionalidades/Respaldos"] = "respaldos",
    ["D:/Proyectos"] = "proyectos",
    ["D:/Recursos"] = "recursos",
    ["D:"] = "base",
    ["/Users/bengy/Proyectos/dynasif"] = "dynasif",
    ["/Users/bengy/Trading/TradingManager"] = "trading",
    ["/Users/bengy/Backups/Respaldos"] = "respaldos",
    ["/Users/bengy/Proyectos"] = "proyectos",
    ["/Users/bengy/Recursos"] = "recursos",
    ["/"] = "base",
  }
  
  local normalized = default_path:gsub("\\", "/"):gsub("/+$", "")
  
  for old_path, alias in pairs(path_map) do
    local normalized_old = old_path:gsub("\\", "/"):gsub("/+$", "")
    if normalized == normalized_old and host[alias] then
      return host[alias]
    end
  end
  
  return default_path
end

M.favorites = {
  d = { path = "D:/", label = "Drive D" },
  e = { path = "E:/", label = "Unidad Externa" },
  recursos = { path = "D:/Recursos", label = "Recursos" },
  documents = { path = vim.fn.expand("~/Documents"), label = "Documents" },
  proyectos = { path = "D:/Proyectos", label = "Projects" },
  trading = { path = "D:/Proyectos/Activos/trading/TradingManager", label = "TradingManager" },
  dynasif = { path = "D:/Pintulac/01_PRODUCCION/dynasif", label = "Dynasif" },
  respaldos = {
    path = "D:/Pintulac/06_RESPALDOS/Funcionalidades/Respaldos-Funcionalidades/Respaldos",
    label = "Respaldos",
  },
}

local suggestions = {
  { text = "abrir dashboard", cmd = "Snacks.dashboard()", category = "abrir" },
  { text = "guardar espacio", cmd = "guardar layout y scripts actuales", category = "abrir" },
  { text = "restaurar ultimo espacio", cmd = "restaurar layout y scripts previos", category = "abrir" },
  { text = "abrir espacio dual", cmd = "elegir 2 proyectos -> 4 ventanas", category = "abrir" },
  { text = "abrir dynasif", cmd = "cd D:/Pintulac/01_PRODUCCION/dynasif + Oil", category = "abrir" },
  {
    text = "abrir respaldos",
    cmd = "cd D:/Pintulac/06_RESPALDOS/Funcionalidades/Respaldos-Funcionalidades/Respaldos + Oil",
    category = "abrir",
  },
  { text = "abrir proyectos", cmd = "cd D:/Proyectos + Oil", category = "abrir" },
  { text = "abrir trading", cmd = "cd D:/Proyectos/Activos/trading/TradingManager + Oil", category = "abrir" },
  { text = "abrir documentos", cmd = "cd ~/Documents + Oil", category = "abrir" },
  { text = "abrir d", cmd = "cd D:/ + Oil", category = "abrir" },
  { text = "abrir unidad externa", cmd = "cd E:/ + Oil", category = "abrir" },
  { text = "abrir recursos", cmd = "cd D:/Recursos + Oil", category = "abrir" },
  { text = "abrir espacio de trabajo", cmd = "elegir carpeta -> arbol (+ opencode opcional)", category = "abrir" },

  { text = "mover ventana a la izquierda", cmd = "<C-w>H", category = "mover" },
  { text = "mover ventana a la derecha", cmd = "<C-w>L", category = "mover" },
  { text = "mover ventana arriba", cmd = "<C-w>K", category = "mover" },
  { text = "mover ventana abajo", cmd = "<C-w>J", category = "mover" },
  { text = "mover cursor izquierda", cmd = "<C-w>h", category = "mover" },
  { text = "mover cursor derecha", cmd = "<C-w>l", category = "mover" },
  { text = "mover cursor arriba", cmd = "<C-w>k", category = "mover" },
  { text = "mover cursor abajo", cmd = "<C-w>j", category = "mover" },
  { text = "mover a ventana 2", cmd = "Asistente: orden visual -> #2", category = "mover" },
  { text = "mover a ventana 1", cmd = "Asistente: orden visual -> #1", category = "mover" },

  { text = "crear ventana izquierda", cmd = "topleft vsplit | enew", category = "crear" },
  { text = "crear ventana derecha", cmd = "botright vsplit | enew", category = "crear" },
  { text = "crear ventana arriba", cmd = "aboveleft split | enew", category = "crear" },
  { text = "crear ventana abajo", cmd = "belowright split | enew", category = "crear" },
  { text = "crear carpeta nueva", cmd = "mkdir <cwd>/nueva", category = "crear" },

  { text = "borrar carpeta ruta", cmd = "delete(<ruta>, rf) with confirm", category = "borrar" },

  { text = "copiar seleccion", cmd = "clipboard <- visual selection", category = "copiar" },
  { text = "copiar archivo", cmd = "clipboard <- current buffer", category = "copiar" },

  {
    text = "ejecutar trading gui",
    cmd = "python -B gui.py (cwd: D:/Proyectos/Activos/trading/TradingManager)",
    category = "ejecutar",
  },
  { text = "ver scripts", cmd = "listar scripts configurados", category = "ejecutar" },
  { text = "ver scripts activos", cmd = "listar procesos python activos del runner", category = "ejecutar" },
  { text = "ver scripts top", cmd = "top 10 scripts mas ejecutados", category = "ejecutar" },
  { text = "ir script trading gui", cmd = "enfocar panel del script", category = "ejecutar" },
  { text = "detener script trading gui", cmd = "detener proceso del script", category = "ejecutar" },
  { text = "detener scripts", cmd = "detener todos los scripts del runner", category = "ejecutar" },

  { text = "ver estado engram", cmd = "engram stats", category = "otros" },
  { text = "ver contexto engram", cmd = "engram context nvim", category = "otros" },
  { text = "memtest ia", cmd = "mostrar ruteo y modelos por defecto", category = "otros" },
  { text = "buscar cambio opencode", cmd = "buscar texto en historial de sesiones", category = "otros" },
  { text = "buscar engram opencode", cmd = "engram search <query> --project nvim", category = "otros" },
  { text = "ver ayuda do", cmd = "mostrar ayuda de comandos", category = "otros" },
  { text = "cerrar ventana", cmd = "close", category = "otros" },
}

local quick_templates = {
  "abrir dynasif",
  "abrir respaldos",
  "abrir trading",
  "abrir unidad externa",
  "abrir recursos",
  "guardar espacio",
  "restaurar ultimo espacio",
  "abrir dashboard",
  "abrir espacio dual",
  "abrir espacio de trabajo",
  "crear ventana arriba",
  "mover ventana a la derecha",
  "mover cursor izquierda",
  "ejecutar trading gui",
  "ver scripts activos",
  "ver estado engram",
  "ver contexto engram",
  "memtest ia",
  "buscar cambio opencode",
  "buscar engram opencode",
  "ver ayuda do",
}

local suggestion_index = {}
local suggestion_cmd_index = {}
for _, s in ipairs(suggestions) do
  local key = s.text:lower()
  suggestion_index[key] = s.text
  suggestion_cmd_index[s.text] = s.cmd
end

local usage_file = vim.fn.stdpath("data") .. "/assistant_usage.json"
local usage_counts = nil

local function load_usage_counts()
  if usage_counts ~= nil then
    return usage_counts
  end

  usage_counts = {}
  if vim.fn.filereadable(usage_file) == 0 then
    return usage_counts
  end

  local ok_read, lines = pcall(vim.fn.readfile, usage_file)
  if not ok_read or not lines or #lines == 0 then
    return usage_counts
  end

  local ok_json, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if ok_json and type(data) == "table" then
    usage_counts = data
  end
  return usage_counts
end

local function save_usage_counts()
  local counts = load_usage_counts()
  local ok_json, encoded = pcall(vim.json.encode, counts)
  if not ok_json or not encoded then
    return
  end
  pcall(vim.fn.writefile, { encoded }, usage_file)
end

local function track_usage(command_text)
  if not command_text or command_text == "" then
    return
  end
  local canonical = suggestion_index[command_text:lower()]
  if not canonical then
    return
  end

  local counts = load_usage_counts()
  counts[canonical] = (tonumber(counts[canonical]) or 0) + 1
  save_usage_counts()
end

local function top_used_commands(limit, category_filter)
  local counts = load_usage_counts()
  local list = {}

  for text, count in pairs(counts) do
    if suggestion_cmd_index[text] then
      if category_filter then
        local keep = false
        for _, s in ipairs(suggestions) do
          if s.text == text and s.category == category_filter then
            keep = true
            break
          end
        end
        if not keep then
          goto continue
        end
      end
      table.insert(list, { text = text, count = tonumber(count) or 0 })
    end
    ::continue::
  end

  table.sort(list, function(a, b)
    if a.count == b.count then
      return a.text < b.text
    end
    return a.count > b.count
  end)

  local out = {}
  for i = 1, math.min(limit or 5, #list) do
    table.insert(out, list[i])
  end
  return out
end

local category_names = {
  abrir = "ABRIR",
  mover = "MOVER",
  crear = "CREAR",
  borrar = "BORRAR",
  copiar = "COPIAR",
  ejecutar = "EJECUTAR",
  otros = "OTROS",
}

local category_order = { "abrir", "mover", "crear", "borrar", "copiar", "ejecutar", "otros" }

local open_text_float
local notify_done

local script_registry = {
  {
    key = "trading-gui",
    name = "trading gui",
    label = "Trading GUI",
    cwd = "D:/Proyectos/Activos/trading/TradingManager",
    cmd = { "python", "-B", "gui.py" },
  },
}

local script_index = {}
for _, s in ipairs(script_registry) do
  script_index[s.name] = s
end

local script_instances = {}
local script_usage_file = vim.fn.stdpath("data") .. "/assistant_script_usage.json"
local script_usage_counts = nil
local workspace_file = vim.fn.stdpath("data") .. "/assistant_workspace.json"
local opencode_part_dir = vim.fn.expand("~/.local/share/opencode/storage/part")
local workspace_state = nil
local script_is_running

local function read_json_file(path)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  local ok_read, lines = pcall(vim.fn.readfile, path)
  if not ok_read or not lines or #lines == 0 then
    return nil
  end
  local ok_json, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if ok_json and type(data) == "table" then
    return data
  end
  return nil
end

local function write_json_file(path, data)
  local ok_json, encoded = pcall(vim.json.encode, data)
  if not ok_json or not encoded then
    return false
  end
  local ok_write = pcall(vim.fn.writefile, { encoded }, path)
  return ok_write
end

local function set_workspace_state(state)
  workspace_state = state
end

local function running_script_keys()
  local keys = {}
  for _, s in ipairs(script_registry) do
    local inst = script_instances[s.key]
    if inst and inst.job and script_is_running(inst) then
      table.insert(keys, s.key)
    end
  end
  return keys
end

local function persist_workspace_state()
  local previous = read_json_file(workspace_file) or {
    layout = "unknown",
    projects = {},
    scripts = {},
  }

  local state = workspace_state or previous
  state.updated_at = os.date("!%Y-%m-%dT%H:%M:%SZ")

  local running = running_script_keys()
  if #running > 0 then
    state.scripts = running
  elseif not state.scripts then
    state.scripts = previous.scripts or {}
  end

  write_json_file(workspace_file, state)
end

local function workspace_compare_state(state)
  local out = {
    layout = state and state.layout or "unknown",
    projects = {},
    scripts = {},
  }

  if state and type(state.projects) == "table" then
    for _, p in ipairs(state.projects) do
      table.insert(out.projects, p)
    end
  end

  if state and type(state.scripts) == "table" then
    for _, s in ipairs(state.scripts) do
      table.insert(out.scripts, s)
    end
  end

  table.sort(out.scripts)
  return out
end

local function current_workspace_state_for_compare()
  local previous = read_json_file(workspace_file) or {
    layout = "unknown",
    projects = {},
    scripts = {},
  }

  local current_cwd = vim.fn.getcwd()
  -- Siempre construir el estado "real" actual basado en CWD y scripts activos,
  -- en lugar de confiar ciegamente en la variable global 'workspace_state'
  -- que puede estar desactualizada si el usuario hizo :cd manual.
  
  local state = {
    layout = workspace_state and workspace_state.layout or "tree_only",
    projects = workspace_state and workspace_state.projects or { current_cwd },
    scripts = previous.scripts or {},
  }

  -- Detectar drift: si tenemos 1 proyecto y no coincide con CWD, actualizamos
  if state.projects and #state.projects == 1 then
    local p1 = state.projects[1]:gsub("\\", "/"):gsub("/+$", ""):lower()
    local cwd = current_cwd:gsub("\\", "/"):gsub("/+$", ""):lower()
    if p1 ~= cwd then
      state.projects = { current_cwd }
      state.layout = "tree_only" -- Asumimos tree_only si cambiamos de dir manualmente
    end
  end

  local running = running_script_keys()
  if #running > 0 then
    state.scripts = running
  end

  return workspace_compare_state(state)
end

local function should_prompt_save_workspace_on_exit()
  local saved = workspace_compare_state(read_json_file(workspace_file) or {})
  local current = current_workspace_state_for_compare()

  local ok_a, enc_saved = pcall(vim.json.encode, saved)
  local ok_b, enc_current = pcall(vim.json.encode, current)
  if not ok_a or not ok_b then
    return true
  end
  return enc_saved ~= enc_current
end

local function load_script_usage_counts()
  if script_usage_counts ~= nil then
    return script_usage_counts
  end

  script_usage_counts = {}
  if vim.fn.filereadable(script_usage_file) == 0 then
    return script_usage_counts
  end

  local ok_read, lines = pcall(vim.fn.readfile, script_usage_file)
  if not ok_read or not lines or #lines == 0 then
    return script_usage_counts
  end

  local ok_json, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if ok_json and type(data) == "table" then
    script_usage_counts = data
  end
  return script_usage_counts
end

local function save_script_usage_counts()
  local counts = load_script_usage_counts()
  local ok_json, encoded = pcall(vim.json.encode, counts)
  if not ok_json or not encoded then
    return
  end
  pcall(vim.fn.writefile, { encoded }, script_usage_file)
end

local function track_script_usage(key)
  local counts = load_script_usage_counts()
  counts[key] = (tonumber(counts[key]) or 0) + 1
  save_script_usage_counts()
end

local function find_script(name)
  local q = (name or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if script_index[q] then
    return script_index[q]
  end

  for _, s in ipairs(script_registry) do
    if s.name:find(q, 1, true) then
      return s
    end
  end
  return nil
end

script_is_running = function(instance)
  if not instance or not instance.job then
    return false
  end
  local status = vim.fn.jobwait({ instance.job }, 0)[1]
  return status == -1
end

local function set_script_win_label(win, label)
  if not (win and vim.api.nvim_win_is_valid(win)) then
    return
  end
  local clean = (label or "Script"):gsub("%%", "%%%%")
  vim.wo[win].winbar = "%#AssistantScriptBar# PyRun @ " .. clean .. " %#WinBar#"
end

local function focus_script_instance(instance)
  if not instance then
    return false
  end

  local wins = vim.fn.win_findbuf(instance.buf)
  if #wins > 0 and vim.api.nvim_win_is_valid(wins[1]) then
    vim.api.nvim_set_current_win(wins[1])
    return true
  end

  if instance.buf and vim.api.nvim_buf_is_valid(instance.buf) then
    vim.cmd("botright split")
    vim.api.nvim_win_set_buf(0, instance.buf)
    set_script_win_label(vim.api.nvim_get_current_win(), instance.label)
    return true
  end

  return false
end

local function run_script(spec)
  if vim.fn.isdirectory(spec.cwd) == 0 then
    vim.notify("Script cwd not found: " .. spec.cwd, vim.log.levels.WARN)
    return
  end

  local existing = script_instances[spec.key]
  if existing and script_is_running(existing) then
    if focus_script_instance(existing) then
      notify_done("Focused running script " .. spec.label, table.concat(spec.cmd, " "))
      return
    end
  end

  vim.cmd("botright split")
  vim.cmd("resize " .. tostring(math.max(10, math.floor(vim.o.lines * 0.35))))
  vim.cmd("lcd " .. vim.fn.fnameescape(spec.cwd))
  vim.cmd("enew")

  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  set_script_win_label(win, spec.label)

  local job = vim.fn.termopen(spec.cmd, {
    cwd = spec.cwd,
    on_exit = function()
      local inst = script_instances[spec.key]
      if inst then
        inst.running = false
      end
    end,
  })

  if job <= 0 then
    vim.notify("Could not start script: " .. spec.name, vim.log.levels.ERROR)
    return
  end

  script_instances[spec.key] = {
    key = spec.key,
    label = spec.label,
    buf = buf,
    win = win,
    job = job,
    cwd = spec.cwd,
    cmd = spec.cmd,
    running = true,
  }
  track_script_usage(spec.key)
  vim.cmd("startinsert")
  notify_done("Started script " .. spec.label, table.concat(spec.cmd, " ") .. " (cwd " .. spec.cwd .. ")")
end

local function list_scripts()
  local lines = {}
  for _, s in ipairs(script_registry) do
    table.insert(lines, "- " .. s.name .. " -> " .. table.concat(s.cmd, " ") .. " | cwd: " .. s.cwd)
  end
  open_text_float("Scripts", lines, "scripts")
end

local function list_active_scripts()
  local lines = {}
  for _, s in ipairs(script_registry) do
    local inst = script_instances[s.key]
    if inst then
      local status = script_is_running(inst) and "RUNNING" or "STOPPED"
      table.insert(lines, "- " .. s.name .. " -> " .. status)
    end
  end
  if #lines == 0 then
    table.insert(lines, "- No hay scripts activos")
  end
  open_text_float("Scripts Activos", lines, "scripts activos")
end

local function list_top_scripts(limit)
  local counts = load_script_usage_counts()
  local rows = {}
  for _, s in ipairs(script_registry) do
    table.insert(rows, { key = s.key, name = s.name, count = tonumber(counts[s.key]) or 0, cmd = table.concat(s.cmd, " ") })
  end
  table.sort(rows, function(a, b)
    if a.count == b.count then
      return a.name < b.name
    end
    return a.count > b.count
  end)

  local lines = {}
  for i = 1, math.min(limit or 10, #rows) do
    local r = rows[i]
    table.insert(lines, string.format("- %s (%d) -> %s", r.name, r.count, r.cmd))
  end
  if #lines == 0 then
    table.insert(lines, "- Sin datos aun")
  end
  open_text_float("Top Scripts", lines, "scripts top")
end

local function stop_script(spec)
  local inst = script_instances[spec.key]
  if not inst or not inst.job then
    vim.notify("Script no esta activo: " .. spec.name, vim.log.levels.WARN)
    return
  end

  if script_is_running(inst) then
    vim.fn.jobstop(inst.job)
  end
  inst.running = false
  notify_done("Stopped script " .. spec.label, "jobstop(" .. tostring(inst.job) .. ")")
end

local function stop_all_scripts()
  local stopped = 0
  for _, s in ipairs(script_registry) do
    local inst = script_instances[s.key]
    if inst and inst.job and script_is_running(inst) then
      vim.fn.jobstop(inst.job)
      inst.running = false
      stopped = stopped + 1
    end
  end
  notify_done("Stopped scripts: " .. tostring(stopped), "stop all script jobs")
end

local function trim(s)
  return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function safe_callback(fn)
  return function(...)
    local ok, err = pcall(fn, ...)
    if not ok then
      vim.schedule(function()
        vim.notify("Assistant callback error: " .. tostring(err), vim.log.levels.ERROR)
      end)
    end
  end
end

notify_done = function(message, cmd)
  vim.notify(string.format("%s [comando: %s]", message, cmd), vim.log.levels.INFO)
end

local function short_dir(path)
  local p = (path or ""):gsub("\\", "/")
  local home = (vim.env.USERPROFILE or vim.env.HOME or ""):gsub("\\", "/")
  if home ~= "" and p:sub(1, #home):lower() == home:lower() then
    p = "~" .. p:sub(#home + 1)
  end
  return p
end

local function set_opencode_win_label(win, buf, dir)
  if not (win and vim.api.nvim_win_is_valid(win) and buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end

  local clean = short_dir(dir):gsub("%%", "%%%%")
  vim.b[buf].opencode_cwd = dir
  vim.wo[win].winbar = "%#AssistantOpencodeBar# OpenCode @ "
    .. clean
    .. " %#WinBar#%= AUTO c>g>x | !C opus | !x fix | !r reporte "
end

local function refresh_opencode_label_for_current_window()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype
  if ft ~= "opencode_terminal" and ft ~= "opencode_ask" then
    return
  end

  local dir = vim.b[buf].opencode_cwd
  if not dir or dir == "" then
    dir = vim.fn.getcwd(-1, 0)
    vim.b[buf].opencode_cwd = dir
  end

  set_opencode_win_label(win, buf, dir)
end

local function path_exists(path)
  return vim.fn.isdirectory(path) == 1
end

local function open_path(path, label)
  if not path_exists(path) then
    vim.notify(string.format("%s not found: %s", label, path), vim.log.levels.WARN)
    return
  end
  vim.cmd("cd " .. vim.fn.fnameescape(path))
  vim.cmd("Oil " .. vim.fn.fnameescape(path))
  notify_done("Opened " .. label, "cd " .. path .. " + Oil")
end

function M.open_favorite(key)
  local fav = M.favorites[key]
  if not fav then
    vim.notify("Favorite not found: " .. tostring(key), vim.log.levels.WARN)
    return
  end
  open_path(fav.path, fav.label)
end

local function favorite_from_target(target)
  local t = target:lower()
  if t == "d" or t == "d:" or t == "unidad d" then
    return "d"
  elseif t == "e" or t == "e:" or t == "unidad e" or t == "unidad externa" or t == "externa" then
    return "e"
  elseif t == "recursos" or t == "recurso" or t == "d:/recursos" then
    return "recursos"
  elseif t == "documentos" or t == "documents" or t == "docs" then
    return "documents"
  elseif t == "proyectos" or t == "projects" or t == "projectos" then
    return "proyectos"
  elseif t == "trading" or t == "tradingmanager" then
    return "trading"
  elseif t == "dynasif" then
    return "dynasif"
  elseif t == "respaldos" or t == "respaldo" then
    return "respaldos"
  end
  return nil
end

local function current_visual_selection()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return nil
  end
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  if #lines == 0 then
    return nil
  end
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    lines[1] = string.sub(lines[1], start_pos[3])
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end
  return table.concat(lines, "\n")
end

local function copy_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  vim.fn.setreg("+", content)
  vim.fn.setreg('"', content)
  notify_done("Copied current file content", "setreg('+', current buffer)")
end

local function copy_selection()
  local text = current_visual_selection()
  if not text then
    vim.notify("No visual selection. Use visual mode first.", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  notify_done("Copied visual selection", "setreg('+', selection)")
end

local function visual_windows()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local pos = vim.fn.win_screenpos(win)
    table.insert(wins, { win = win, row = pos[1] or 0, col = pos[2] or 0 })
  end
  table.sort(wins, function(a, b)
    if a.row == b.row then
      return a.col < b.col
    end
    return a.row < b.row
  end)
  return wins
end

local function goto_window(index)
  local wins = visual_windows()
  local item = wins[index]
  if not item then
    vim.notify(string.format("Window %d not found", index), vim.log.levels.WARN)
    return
  end
  vim.api.nvim_set_current_win(item.win)
  notify_done("Moved to window " .. index, "focus visual window #" .. index)
end

local function create_window(direction)
  local wins = visual_windows()
  local left_anchor = wins[1] and wins[1].win or nil

  if left_anchor and (direction == "arriba" or direction == "abajo") then
    pcall(vim.api.nvim_set_current_win, left_anchor)
  end

  if direction == "arriba" then
    vim.cmd("aboveleft split")
    vim.cmd("enew")
    notify_done("Created new window above", "aboveleft split | enew")
  elseif direction == "abajo" then
    vim.cmd("belowright split")
    vim.cmd("enew")
    notify_done("Created new window below", "belowright split | enew")
  elseif direction == "izquierda" then
    vim.cmd("topleft vsplit")
    vim.cmd("enew")
    notify_done("Created new window left", "topleft vsplit | enew")
  elseif direction == "derecha" then
    vim.cmd("botright vsplit")
    vim.cmd("enew")
    notify_done("Created new window right", "botright vsplit | enew")
  else
    vim.notify("Direction not supported. Use arriba|abajo|izquierda|derecha", vim.log.levels.WARN)
  end
end

local function move_window(direction)
  if direction == "arriba" then
    vim.cmd("wincmd K")
    notify_done("Moved window to top", "<C-w>K")
  elseif direction == "abajo" then
    vim.cmd("wincmd J")
    notify_done("Moved window to bottom", "<C-w>J")
  elseif direction == "izquierda" then
    vim.cmd("wincmd H")
    notify_done("Moved window to left", "<C-w>H")
  elseif direction == "derecha" then
    vim.cmd("wincmd L")
    notify_done("Moved window to right", "<C-w>L")
  else
    vim.notify("Direction not supported. Use arriba|abajo|izquierda|derecha", vim.log.levels.WARN)
  end
end

local function move_cursor(direction)
  if direction == "arriba" then
    vim.cmd("wincmd k")
    notify_done("Moved cursor up", "<C-w>k")
  elseif direction == "abajo" then
    vim.cmd("wincmd j")
    notify_done("Moved cursor down", "<C-w>j")
  elseif direction == "izquierda" then
    vim.cmd("wincmd h")
    notify_done("Moved cursor left", "<C-w>h")
  elseif direction == "derecha" then
    vim.cmd("wincmd l")
    notify_done("Moved cursor right", "<C-w>l")
  else
    vim.notify("Direction not supported. Use arriba|abajo|izquierda|derecha", vim.log.levels.WARN)
  end
end

local function normalize_direction(dir)
  local d = trim((dir or ""):lower())
  if d == "arriba" or d == "up" then
    return "arriba"
  elseif d == "abajo" or d == "down" then
    return "abajo"
  elseif d == "izquierda" or d == "isquierda" or d == "izq" or d == "left" then
    return "izquierda"
  elseif d == "derecha" or d == "der" or d == "right" then
    return "derecha"
  end
  return nil
end

local function create_folder(folder_name, base_path)
  local cwd = vim.fn.getcwd()
  local base = trim(base_path) ~= "" and trim(base_path) or cwd
  local name = trim(folder_name)
  if name == "" then
    vim.notify("Missing folder name", vim.log.levels.WARN)
    return
  end

  local full
  if name:match("^[A-Za-z]:/") or name:match("^[A-Za-z]:\\") then
    full = name
  else
    full = base .. "/" .. name
  end
  full = full:gsub("\\", "/")

  local ok = vim.fn.mkdir(full, "p")
  if ok == 0 and vim.fn.isdirectory(full) == 0 then
    vim.notify("Could not create folder: " .. full, vim.log.levels.ERROR)
    return
  end
  notify_done("Folder created", "mkdir -p " .. full)
end

local function delete_folder(path)
  local p = trim(path)
  if p == "" then
    vim.notify("Missing folder path", vim.log.levels.WARN)
    return
  end

  local full = p
  if not (p:match("^[A-Za-z]:/") or p:match("^[A-Za-z]:\\")) then
    full = vim.fn.getcwd() .. "/" .. p
  end
  full = full:gsub("\\", "/")

  if vim.fn.isdirectory(full) == 0 then
    vim.notify("Folder not found: " .. full, vim.log.levels.WARN)
    return
  end

  local answer = vim.fn.confirm("Delete folder?\n" .. full, "&Yes\n&No", 2)
  if answer ~= 1 then
    vim.notify("Cancelled", vim.log.levels.INFO)
    return
  end

  local ok = vim.fn.delete(full, "rf")
  if ok ~= 0 then
    vim.notify("Could not delete folder: " .. full, vim.log.levels.ERROR)
    return
  end
  notify_done("Folder deleted", "delete(" .. full .. ", 'rf')")
end

local function open_workspace_two_panes(dir)
  if vim.fn.isdirectory(dir) == 0 then
    vim.notify("Folder not found: " .. dir, vim.log.levels.WARN)
    return
  end

  vim.cmd("only")
  vim.cmd("cd " .. vim.fn.fnameescape(dir))
  vim.cmd("Oil " .. vim.fn.fnameescape(dir))

  local left_win = vim.api.nvim_get_current_win()
  vim.cmd("botright vsplit")
  vim.cmd("lcd " .. vim.fn.fnameescape(dir))
  vim.cmd("enew")

  local job = vim.fn.termopen("opencode", { cwd = dir })
  if job <= 0 then
    vim.notify("Could not start opencode in workspace", vim.log.levels.ERROR)
    pcall(vim.api.nvim_set_current_win, left_win)
    return
  end

  vim.bo.filetype = "opencode_terminal"
  set_opencode_win_label(vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf(), dir)
  vim.cmd("startinsert")
  set_workspace_state({ layout = "two_panes", projects = { dir } })
  notify_done("Opened workspace (tree left, opencode right)", "only | Oil | botright vsplit | termopen(opencode)")
end

local function start_opencode_in_current_window(dir)
  vim.cmd("lcd " .. vim.fn.fnameescape(dir))
  vim.cmd("enew")

  local job = vim.fn.termopen("opencode", { cwd = dir })
  if job <= 0 then
    vim.notify("Could not start opencode", vim.log.levels.ERROR)
    return false
  end

  vim.bo.filetype = "opencode_terminal"
  set_opencode_win_label(vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf(), dir)
  vim.cmd("startinsert")
  return true
end

local function open_dual_projects_layout(dir_a, dir_b)
  if vim.fn.isdirectory(dir_a) == 0 or vim.fn.isdirectory(dir_b) == 0 then
    vim.notify("One of the selected project folders does not exist", vim.log.levels.ERROR)
    return
  end

  vim.cmd("only")

  -- Top-left: project A tree
  vim.cmd("cd " .. vim.fn.fnameescape(dir_a))
  vim.cmd("Oil " .. vim.fn.fnameescape(dir_a))
  local top_left = vim.api.nvim_get_current_win()

  -- Top-right: project A opencode
  vim.cmd("botright vsplit")
  local top_right = vim.api.nvim_get_current_win()
  if not start_opencode_in_current_window(dir_a) then
    return
  end

  -- Bottom-left: project B tree
  pcall(vim.api.nvim_set_current_win, top_left)
  vim.cmd("belowright split")
  local bottom_left = vim.api.nvim_get_current_win()
  vim.cmd("lcd " .. vim.fn.fnameescape(dir_b))
  vim.cmd("Oil " .. vim.fn.fnameescape(dir_b))

  -- Bottom-right: project B opencode
  pcall(vim.api.nvim_set_current_win, top_right)
  vim.cmd("belowright split")
  local _bottom_right = vim.api.nvim_get_current_win()
  if not start_opencode_in_current_window(dir_b) then
    pcall(vim.api.nvim_set_current_win, bottom_left)
    return
  end

  set_workspace_state({ layout = "dual", projects = { dir_a, dir_b } })
  notify_done(
    "Opened dual workspace (4 panes)",
    "only | top: tree+opencode(project A) | bottom: tree+opencode(project B)"
  )
end

local function open_workspace_cross_layout(dir)
  if vim.fn.isdirectory(dir) == 0 then
    vim.notify("Folder not found: " .. dir, vim.log.levels.WARN)
    return false
  end

  local candidates = {}
  for _, item in ipairs(visual_windows()) do
    if vim.api.nvim_win_get_config(item.win).relative == "" then
      table.insert(candidates, item)
    end
  end

  if #candidates < 2 then
    return false
  end

  local left = candidates[1]
  local right = candidates[1]
  for i = 2, #candidates do
    if candidates[i].col < left.col then
      left = candidates[i]
    end
    if candidates[i].col > right.col then
      right = candidates[i]
    end
  end

  if left.win == right.win then
    return false
  end

  if not (left and right and vim.api.nvim_win_is_valid(left.win) and vim.api.nvim_win_is_valid(right.win)) then
    return false
  end

  pcall(vim.api.nvim_set_current_win, left.win)
  vim.cmd("aboveleft split")
  vim.cmd("lcd " .. vim.fn.fnameescape(dir))
  vim.cmd("Oil " .. vim.fn.fnameescape(dir))

  pcall(vim.api.nvim_set_current_win, right.win)
  vim.cmd("aboveleft split")
  vim.cmd("lcd " .. vim.fn.fnameescape(dir))
  vim.cmd("enew")

  local job = vim.fn.termopen("opencode", { cwd = dir })
  if job <= 0 then
    vim.notify("Could not start opencode in cross layout", vim.log.levels.ERROR)
    return true
  end

  vim.bo.filetype = "opencode_terminal"
  set_opencode_win_label(vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf(), dir)
  vim.cmd("startinsert")
  set_workspace_state({ layout = "cross_single", projects = { dir } })
  notify_done("Opened workspace cross layout", "preserved bottom row + opened top tree/opencode")
  return true
end

local function open_dual_projects_picker()
  local base = {
    { label = "Dynasif", key = "dynasif" },
    { label = "Trading", key = "trading" },
    { label = "Respaldos", key = "respaldos" },
    { label = "Proyectos", key = "proyectos" },
    { label = "Unidad Externa", key = "e" },
    { label = "Recursos", key = "recursos" },
  }

  local first_labels = {}
  for _, p in ipairs(base) do
    table.insert(first_labels, p.label)
  end

  vim.ui.select(first_labels, { prompt = "Proyecto A" }, safe_callback(function(first)
    if not first then
      return
    end

    local first_key = nil
    for _, p in ipairs(base) do
      if p.label == first then
        first_key = p.key
        break
      end
    end
    if not first_key then
      return
    end

    local second_options = {}
    for _, p in ipairs(base) do
      if p.key ~= first_key then
        table.insert(second_options, p)
      end
    end

    local second_labels = {}
    for _, p in ipairs(second_options) do
      table.insert(second_labels, p.label)
    end

    vim.ui.select(second_labels, { prompt = "Proyecto B" }, safe_callback(function(second)
      if not second then
        return
      end

      local second_key = nil
      for _, p in ipairs(second_options) do
        if p.label == second then
          second_key = p.key
          break
        end
      end
      if not second_key then
        return
      end

      local fav_a = M.favorites[first_key]
      local fav_b = M.favorites[second_key]
      if not fav_a or not fav_b then
        vim.notify("Could not resolve selected projects", vim.log.levels.ERROR)
        return
      end

      open_dual_projects_layout(fav_a.path, fav_b.path)
    end))
  end))
end

local function restore_last_workspace_state()
  local state = read_json_file(workspace_file)
  if not state or type(state) ~= "table" then
    vim.notify("No hay espacio de trabajo guardado", vim.log.levels.WARN)
    return false
  end

  local projects = state.projects or {}
  local layout = state.layout or ""

  if layout == "dual" and projects[1] and projects[2] then
    open_dual_projects_layout(projects[1], projects[2])
  elseif (layout == "two_panes" or layout == "cross_single") and projects[1] then
    open_workspace_two_panes(projects[1])
  elseif layout == "tree_only" and projects[1] then
    vim.cmd("only")
    vim.cmd("cd " .. vim.fn.fnameescape(projects[1]))
    vim.cmd("Oil " .. vim.fn.fnameescape(projects[1]))
    set_workspace_state({ layout = "tree_only", projects = { projects[1] } })
    notify_done("Restored tree workspace", "only | cd " .. projects[1] .. " | Oil")
  else
    vim.notify("Workspace guardado invalido o incompleto", vim.log.levels.WARN)
    return false
  end

  local scripts = state.scripts or {}
  if type(scripts) == "table" and #scripts > 0 then
    vim.defer_fn(function()
      for _, key in ipairs(scripts) do
        for _, spec in ipairs(script_registry) do
          if spec.key == key then
            run_script(spec)
            break
          end
        end
      end
    end, 180)
  end

  notify_done("Restored last workspace", "workspace + scripts")
  return true
end

local function save_workspace_snapshot()
  local state = workspace_state
  if not state or type(state) ~= "table" then
    local cwd = vim.fn.getcwd()
    if vim.fn.isdirectory(cwd) == 1 then
      state = { layout = "tree_only", projects = { cwd } }
      set_workspace_state(state)
    end
  end

  persist_workspace_state()
  notify_done("Saved workspace snapshot", "assistant_workspace.json")
end

local function open_tree_new_window()
  local choices = {
    { label = "Dynasif", key = "dynasif" },
    { label = "Trading", key = "trading" },
    { label = "Proyectos", key = "proyectos" },
    { label = "Unidad Externa", key = "e" },
    { label = "Recursos", key = "recursos" },
    { label = "Directorio actual", key = "cwd" },
    { label = "Cancelar", key = "cancel" },
  }

  local labels = {}
  for _, c in ipairs(choices) do
    table.insert(labels, c.label)
  end

  vim.ui.select(labels, { prompt = "Arbol: elegir carpeta" }, safe_callback(function(choice)
    if not choice then
      return
    end

    local selected = nil
    for _, c in ipairs(choices) do
      if c.label == choice then
        selected = c
        break
      end
    end

    if not selected or selected.key == "cancel" then
      return
    end

    local path = vim.fn.getcwd()
    local label = "Current"
    if selected.key ~= "cwd" then
      local fav = M.favorites[selected.key]
      if not fav then
        vim.notify("Favorite not found: " .. selected.key, vim.log.levels.WARN)
        return
      end
      path = fav.path
      label = fav.label
    end

    if vim.fn.isdirectory(path) == 0 then
      vim.notify("Folder not found: " .. path, vim.log.levels.WARN)
      return
    end

    local origin_win = vim.api.nvim_get_current_win()
    local answer = vim.fn.confirm("Abrir OpenCode para este directorio?", "&Si\n&No", 1)

    if answer == 1 then
      local normal_wins = 0
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(win).relative == "" then
          normal_wins = normal_wins + 1
        end
      end

      if normal_wins >= 2 and open_workspace_cross_layout(path) then
        return
      end

      open_workspace_two_panes(path)
      return
    end

    if vim.api.nvim_win_is_valid(origin_win) then
      pcall(vim.api.nvim_set_current_win, origin_win)
    end
    vim.cmd("cd " .. vim.fn.fnameescape(path))
    vim.cmd("Oil " .. vim.fn.fnameescape(path))
    set_workspace_state({ layout = "tree_only", projects = { path } })
    notify_done("Opened tree (" .. label .. ")", "cd " .. path .. " | Oil")
  end))
end

local function open_dashboard()
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("Snacks is not available", vim.log.levels.ERROR)
    return
  end
  snacks.dashboard()
  notify_done("Opened dashboard", "Snacks.dashboard()")
end

open_text_float = function(title, lines, cmd_label)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"

  local content = { "# " .. title, "" }
  for _, l in ipairs(lines or {}) do
    table.insert(content, l)
  end
  if #content <= 2 then
    table.insert(content, "(sin resultados)")
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  local width = math.floor(vim.o.columns * 0.75)
  local height = math.min(math.floor(vim.o.lines * 0.65), math.max(#content + 2, 10))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    border = "rounded",
    style = "minimal",
    title = title,
    title_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
  if cmd_label then
    notify_done("Opened " .. title, cmd_label)
  end
end

local function engram_status()
  local lines = vim.fn.systemlist({ "engram", "stats" })
  if vim.v.shell_error ~= 0 then
    vim.notify("Engram no disponible en PATH", vim.log.levels.ERROR)
    return
  end
  open_text_float("Engram Estado", lines, "engram stats")
end

local function engram_context()
  local lines = vim.fn.systemlist({ "engram", "context", "nvim" })
  if vim.v.shell_error ~= 0 then
    vim.notify("No se pudo obtener contexto de Engram", vim.log.levels.ERROR)
    return
  end
  open_text_float("Engram Context (nvim)", lines, "engram context nvim")
end

local function engram_search(query)
  local q = trim(query)
  if q == "" then
    vim.notify("Falta termino de busqueda. Ej: engram b opencode", vim.log.levels.WARN)
    return
  end

  local lines = vim.fn.systemlist({ "engram", "search", q, "--project", "nvim" })
  if vim.v.shell_error ~= 0 then
    vim.notify("No se pudo buscar en Engram", vim.log.levels.ERROR)
    return
  end
  open_text_float("Engram Busqueda: " .. q, lines, "engram search \"" .. q .. "\" --project nvim")
end

local function normalize_help_category(input)
  local s = trim((input or ""):lower())
  if s == "" then
    return nil
  end
  if s == "abrir" then
    return "abrir"
  elseif s == "mover" then
    return "mover"
  elseif s == "crear" then
    return "crear"
  elseif s == "borrar" then
    return "borrar"
  elseif s == "copiar" then
    return "copiar"
  elseif s == "ejecutar" then
    return "ejecutar"
  elseif s == "otros" then
    return "otros"
  end
  return nil
end

local function do_help(category_filter)
  local lines = {}
  local grouped = {}
  for _, cat in ipairs(category_order) do
    grouped[cat] = {}
  end

  local seen = {}
  for _, s in ipairs(suggestions) do
    if not seen[s.text] then
      seen[s.text] = true
      local cat = s.category or "otros"
      grouped[cat] = grouped[cat] or {}
      table.insert(grouped[cat], s)
    end
  end

  local title = "Comandos de :do"
  if category_filter then
    title = title .. " (" .. (category_names[category_filter] or category_filter:upper()) .. ")"
  end

  table.insert(lines, title)
  table.insert(lines, "")

  local top = top_used_commands(5, category_filter)
  table.insert(lines, "## TOP 5 USADOS")
  if #top == 0 then
    table.insert(lines, "- Sin datos aun")
  else
    for _, t in ipairs(top) do
      local cmd = suggestion_cmd_index[t.text] or ""
      table.insert(lines, string.format("- %s (%d) -> %s", t.text, t.count, cmd))
    end
  end
  table.insert(lines, "")

  for _, cat in ipairs(category_order) do
    if category_filter and cat ~= category_filter then
      goto continue
    end

    local list = grouped[cat] or {}
    if #list > 0 then
      table.insert(lines, "## " .. (category_names[cat] or cat:upper()))
      table.sort(list, function(a, b)
        return a.text < b.text
      end)
      for _, it in ipairs(list) do
        table.insert(lines, "- " .. it.text .. " -> " .. it.cmd)
      end
      table.insert(lines, "")
    end

    ::continue::
  end

  open_text_float("Ayuda :Do", lines, category_filter and ("do ayuda " .. category_filter) or "do ayuda")
end

local function show_ai_memtest()
  local lines = {
    "AI Router Memtest",
    "",
    "Sin tag (auto por intencion):",
    "- coding/desarrollo -> c -> anthropic/claude-sonnet-4-6",
    "- investigacion profunda -> g -> google/gemini-2.5-flash",
    "- error/debug/fix -> x -> openai/gpt-5.3-codex",
    "- informe/reporte -> r -> openai/gpt-5.3-codex",
    "",
    "Fallback auto principal:",
    "- c falla -> g -> x",
    "",
    "Overrides manuales:",
    "- !c <prompt> -> Claude Sonnet 4.6",
    "- !g <prompt> -> Gemini 2.5 Flash",
    "- !G <prompt> -> Gemini 2.5 Pro (fallback Flash)",
    "- !x <prompt> -> Codex (fix/debug)",
    "- !r <prompt> -> Codex (reporte)",
    "- !C <prompt> -> Claude Opus 4.6 (turbo)",
    "- !d <prompt> -> directo (sin routing)",
  }
  open_text_float("Memtest IA", lines, "memtest ia")
end

local function search_opencode_change(query)
  local q = trim(query or "")
  if q == "" then
    vim.ui.input({ prompt = "Buscar cambio OpenCode > " }, function(input)
      if input and trim(input) ~= "" then
        search_opencode_change(trim(input))
      end
    end)
    return
  end

  local ql = q:lower()
  local too_generic = {
    opencode = true,
    cambio = true,
    cambios = true,
    buscar = true,
    session = true,
    sesion = true,
  }
  if too_generic[ql] then
    vim.ui.input({ prompt = "Busqueda muy general. Especifica > " }, function(input)
      if input and trim(input) ~= "" then
        search_opencode_change(trim(input))
      end
    end)
    return
  end

  local terms = {}
  for token in ql:gmatch("%S+") do
    table.insert(terms, token)
  end
  if #terms == 0 then
    vim.notify("Falta termino de busqueda", vim.log.levels.WARN)
    return
  end

  if vim.fn.isdirectory(opencode_part_dir) == 0 then
    vim.notify("No existe historial de OpenCode: " .. opencode_part_dir, vim.log.levels.WARN)
    return
  end

  local files = vim.fn.systemlist({ "rg", "-l", "-i", "-F", q, opencode_part_dir, "-g", "*.json" })
  if vim.v.shell_error ~= 0 and #files == 0 then
    vim.notify("No matches in OpenCode history for: " .. q, vim.log.levels.INFO)
    return
  end

  local by_session = {}

  for _, file in ipairs(files) do
    local data = read_json_file(file)
    if data and data.type == "text" and type(data.text) == "string" and type(data.sessionID) == "string" then
      local tl = data.text:lower()
      local all_terms = true
      for _, term in ipairs(terms) do
        if not tl:find(term, 1, true) then
          all_terms = false
          break
        end
      end
      if all_terms then
        local entry = by_session[data.sessionID]
        if not entry then
          local timestamp = 0
          if data.time and data.time.created then
            timestamp = math.floor(data.time.created / 1000)
          end
          entry = { hits = 0, preview = "", messageID = data.messageID or "", time = timestamp }
          by_session[data.sessionID] = entry
        end
        entry.hits = entry.hits + 1
        if entry.time == 0 and data.time and data.time.created then
          entry.time = math.floor(data.time.created / 1000)
        end
        if entry.preview == "" then
          local one = data.text
            :gsub("<system%-reminder>.-</system%-reminder>", " ")
            :gsub("\n", " ")
            :gsub("%s+", " ")
          if #one > 180 then
            one = one:sub(1, 180) .. "..."
          end
          entry.preview = one
        end
      end
    end
  end

  local rows = {}
  for sessionID, info in pairs(by_session) do
    table.insert(rows, {
      sessionID = sessionID,
      hits = info.hits,
      preview = info.preview,
      messageID = info.messageID,
      time = info.time,
    })
  end

  table.sort(rows, function(a, b)
    if a.time > 0 and b.time > 0 and a.time ~= b.time then
      return a.time > b.time -- Sort by date descending (newest first)
    end
    if a.hits == b.hits then
      return a.sessionID > b.sessionID
    end
    return a.hits > b.hits
  end)

  if #rows == 0 then
    vim.notify("No text matches after parsing for: " .. q, vim.log.levels.INFO)
    return
  end

  local selection_items = {}
  for i, r in ipairs(rows) do
    if i > 25 then break end
    local date_str = (r.time > 0) and os.date("%Y-%m-%d %H:%M", r.time) or "no-date"
    local label = string.format("[%d] %s (%s) hits=%d", i, r.sessionID, date_str, r.hits)
    if r.preview ~= "" then
      label = label .. " | " .. r.preview
    end
    table.insert(selection_items, { label = label, session = r.sessionID })
  end

  vim.ui.select(selection_items, {
    prompt = "Resultados busqueda OpenCode (" .. q .. ")",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then return end
    
    local answer = vim.fn.confirm("Abrir sesion: " .. choice.session .. "?", "&Si\n&No", 1)
    if answer == 1 then
      start_opencode_in_current_window(vim.fn.getcwd())
      -- Esperar a que terminal arranque y enviar comando
      vim.defer_fn(function()
        local buf = vim.api.nvim_get_current_buf()
        local job = vim.b[buf].terminal_job_id
        if job and job > 0 then
          vim.fn.chansend(job, "opencode -s " .. choice.session .. "\r")
        end
      end, 500)
    end
  end)
end

function M.execute(input)
  local raw = trim(input)
  local lower = raw:lower()
  if raw == "" then
    return
  end

  track_usage(raw)

  local routed = raw:match("^![CcGgDdXxRr]%s+.+$")
  if routed then
    local router = _G.OpencodeRoutePrompt
    if type(router) ~= "function" then
      vim.notify("OpenCode router no disponible. Abre OpenCode una vez e intenta de nuevo.", vim.log.levels.WARN)
      return
    end
    router(raw)
    notify_done("Routed prompt", raw)
    return
  end

  if lower == "memtest ia" or lower == "ver memtest ia" or lower == "estado ruteo ia" then
    show_ai_memtest()
    return
  end

  local search_change_q = raw:match("^[Bb]uscar%s+cambio%s+(.+)$")
    or raw:match("^[Bb]uscar%s+en%s+opencode%s+(.+)$")
    or raw:match("^[Cc]ambio%s+opencode%s+(.+)$")
  if search_change_q then
    search_opencode_change(search_change_q)
    return
  end

  local target = lower:match("^abre%s+(.+)$") or lower:match("^abrir%s+(.+)$")
  if target then
    local fav = favorite_from_target(target)
    if fav then
      M.open_favorite(fav)
      return
    end
    if target == "opencode en cwd" or target == "opencode" then
      vim.cmd("botright vsplit")
      start_opencode_in_current_window(vim.fn.getcwd())
      return
    end
    if target:match("^[A-Za-z]:") or target:match("^/") then
      open_path(raw:match("^[Aa]b[rri]+%s+(.+)$") or target, "Path")
      return
    end
  end

  if lower == "ver scripts" or lower == "scripts" then
    list_scripts()
    return
  end
  if lower == "ver scripts activos" or lower == "scripts activos" then
    list_active_scripts()
    return
  end
  if lower == "ver scripts top" or lower == "scripts top" then
    list_top_scripts(10)
    return
  end

  local run_script_name = lower:match("^ejecutar%s+(.+)$")
  if run_script_name then
    local spec = find_script(run_script_name)
    if spec then
      run_script(spec)
    else
      vim.notify("Script no registrado: " .. run_script_name, vim.log.levels.WARN)
    end
    return
  end

  local focus_script_name = lower:match("^ir%s+script%s+(.+)$")
  if focus_script_name then
    local spec = find_script(focus_script_name)
    if spec and script_instances[spec.key] and focus_script_instance(script_instances[spec.key]) then
      notify_done("Focused script " .. spec.label, "focus script panel")
    else
      vim.notify("Script no activo: " .. focus_script_name, vim.log.levels.WARN)
    end
    return
  end

  if lower == "detener scripts" then
    stop_all_scripts()
    return
  end

  local stop_script_name = lower:match("^detener%s+script%s+(.+)$")
  if stop_script_name then
    local spec = find_script(stop_script_name)
    if spec then
      stop_script(spec)
    else
      vim.notify("Script no registrado: " .. stop_script_name, vim.log.levels.WARN)
    end
    return
  end

  local goto_path = raw:match("^[Ii]r%s+a%s+(.+)$")
  if goto_path then
    open_path(trim(goto_path), "Path")
    return
  end

  if lower == "copia archivo" or lower == "copiar archivo" or lower == "copia contenido del archivo" then
    copy_buffer()
    return
  end
  if lower == "copia seleccion" or lower == "copiar seleccion" then
    copy_selection()
    return
  end

  local create_arg = raw:match("^[Cc]rea[r]?%s+carpeta%s+(.+)$")
  if create_arg then
    local name, base = create_arg:match("^(.-)%s+[Ee]n%s+(.+)$")
    create_folder(name or create_arg, base)
    return
  end

  local del_arg = raw:match("^[Bb]orra[r]?%s+carpeta%s+(.+)$")
  if del_arg then
    delete_folder(del_arg)
    return
  end

  local w = lower:match("^pasar%s+a%s+ventana%s+(%d+)$") or lower:match("^mover%s+a%s+ventana%s+(%d+)$")
  if w then
    goto_window(tonumber(w))
    return
  end

  local move_dir = lower:match("^mover%s+ventana%s+a%s+(.+)$")
    or lower:match("^mover%s+ventana%s+(.+)$")
  if move_dir then
    local parsed = normalize_direction(move_dir)
    if parsed then
      move_window(parsed)
      return
    end
  end

  local cursor_dir = lower:match("^mover%s+cursor%s+a%s+(.+)$")
    or lower:match("^mover%s+cursor%s+(.+)$")
    or lower:match("^cursor%s+(.+)$")
  if cursor_dir then
    local parsed = normalize_direction(cursor_dir)
    if parsed then
      move_cursor(parsed)
      return
    end
  end

  local dir = lower:match("^crea[r]?%s+ventana%s+(.-)$")
    or lower:match("^crea[r]?%s+una%s+ventana%s+(.-)$")
    or lower:match("^crear%s+nueva%s+ventana%s+(.-)$")
  if dir then
    local parsed = normalize_direction(dir)
    if parsed then
      create_window(parsed)
      return
    end
  end

  local short_dir = lower:match("^ventana%s+(arriba|abajo|izquierda|isquierda|izq|derecha|der)$")
  if short_dir then
    local parsed = normalize_direction(short_dir)
    if parsed then
      create_window(parsed)
      return
    end
  end

  local split_dir = lower:match("^split%s+(arriba|abajo|izquierda|isquierda|izq|derecha|der|left|right|up|down)$")
  if split_dir then
    local parsed = normalize_direction(split_dir)
    if parsed then
      create_window(parsed)
      return
    end
  end

  if lower == "crear ventana" or lower == "crea ventana" then
    vim.notify("Falta direccion: arriba|abajo|izquierda|derecha", vim.log.levels.WARN)
    return
  end

  if lower == "cerrar ventana" then
    vim.cmd("close")
    notify_done("Closed current window", "close")
    return
  end
  if lower == "abrir espacio de trabajo" then
    open_tree_new_window()
    return
  end
  if lower == "restaurar ultimo espacio" or lower == "restaurar espacio" then
    restore_last_workspace_state()
    return
  end
  if lower == "guardar espacio" or lower == "guardar espacio de trabajo" or lower == "guardar workspace" then
    save_workspace_snapshot()
    return
  end
  if lower == "abrir espacio dual" or lower == "crear espacio dual" or lower == "espacio dual" then
    open_dual_projects_picker()
    return
  end
  if lower == "abrir dashboard" or lower == "dashboard" or lower == "abre dashboard" or lower == "abre snoopy" then
    open_dashboard()
    return
  end
  if lower == "ver estado engram" or lower == "engram e" or lower == "engram estado" or lower == "estado engram" then
    engram_status()
    return
  end
  if lower == "ver contexto engram" or lower == "engram c" or lower == "engram contexto" or lower == "contexto engram" then
    engram_context()
    return
  end
  local help_cat = lower:match("^ayuda%s+([%a]+)$")
    or lower:match("^ayuda%s+do%s+([%a]+)$")
    or lower:match("^ver%s+ayuda%s+do%s+([%a]+)$")
  if help_cat then
    local normalized = normalize_help_category(help_cat)
    if normalized then
      do_help(normalized)
      return
    end
  end
  if lower == "ayuda" or lower == "ayuda do" or lower == "ver ayuda do" then
    do_help()
    return
  end
  local engram_query = raw:match("^[Ee]ngram%s+b%s+(.+)$")
    or raw:match("^[Bb]uscar%s+engram%s+(.+)$")
    or raw:match("^[Bb]uscar%s+en%s+engram%s+(.+)$")
  if engram_query then
    engram_search(engram_query)
    return
  end

  local router = _G.OpencodeRoutePrompt
  if type(router) == "function" then
    local ok = router(raw)
    if ok then
      notify_done("Routed prompt (auto)", raw)
      return
    end
  end

  vim.notify(
    "No entendi ese comando. Prueba: abrir espacio de trabajo | abrir espacio dual | ejecutar trading gui",
    vim.log.levels.WARN
  )
end

local function context_suggestions()
  local ft = vim.bo.filetype
  local items = {}

  if ft == "oil" then
    table.insert(items, { text = "crear carpeta nueva", cmd = "mkdir <cwd>/nueva", category = "crear" })
    table.insert(items, { text = "borrar carpeta ruta", cmd = "delete(<ruta>, rf) with confirm", category = "borrar" })
  elseif ft == "opencode_terminal" or ft == "opencode_ask" then
    table.insert(items, { text = "mover cursor izquierda", cmd = "<C-w>h", category = "mover" })
    table.insert(items, { text = "mover a ventana 1", cmd = "Asistente: orden visual -> #1", category = "mover" })
    table.insert(items, { text = "cerrar ventana", cmd = "close", category = "otros" })
  else
    -- Usar resolve_host_path para obtener rutas del host actual
    table.insert(items, { text = "abrir dynasif", cmd = "cd " .. resolve_host_path("D:/Pintulac/01_PRODUCCION/dynasif") .. " + Oil", category = "abrir" })
    table.insert(
      items,
      {
        text = "abrir respaldos",
        cmd = "cd " .. resolve_host_path("D:/Pintulac/06_RESPALDOS/Funcionalidades/Respaldos-Funcionalidades/Respaldos") .. " + Oil",
        category = "abrir",
      }
    )
    table.insert(items, { text = "abrir trading", cmd = "cd " .. resolve_host_path("D:/Proyectos/Activos/trading/TradingManager") .. " + Oil", category = "abrir" })
    table.insert(items, { text = "abrir unidad externa", cmd = "cd E:/ + Oil", category = "abrir" })
    table.insert(items, { text = "abrir recursos", cmd = "cd " .. resolve_host_path("D:/Recursos") .. " + Oil", category = "abrir" })
    table.insert(items, {
      text = "ejecutar trading gui",
      cmd = "python -B gui.py (cwd: " .. resolve_host_path("D:/Proyectos/Activos/trading/TradingManager") .. ")",
      category = "ejecutar",
    })
  end

  return items
end

function M.open_menu()
  local items = context_suggestions()
  for _, s in ipairs(suggestions) do
    table.insert(items, s)
  end

  local uniq = {}
  local grouped = {}
  for _, cat in ipairs(category_order) do
    grouped[cat] = {}
  end

  for _, it in ipairs(items) do
    if not uniq[it.text] then
      uniq[it.text] = true
      local cat = it.category or "otros"
      grouped[cat] = grouped[cat] or {}
      table.insert(grouped[cat], it)
    end
  end

  for _, cat in ipairs(category_order) do
    table.sort(grouped[cat], function(a, b)
      return a.text:lower() > b.text:lower()
    end)
  end

  local options = { "Escribir comando..." }
  local headers = { ["Escribir comando..."] = true }

  table.insert(options, "=== ATAJOS RAPIDOS ===")
  headers["=== ATAJOS RAPIDOS ==="] = true
  for _, cmd in ipairs(quick_templates) do
    table.insert(options, string.format("  • %s  ->  [plantilla]", cmd))
  end

  for _, cat in ipairs(category_order) do
    local list = grouped[cat] or {}
    if #list > 0 then
      local header = string.format("=== OPCION %s ===", category_names[cat] or cat:upper())
      table.insert(options, header)
      headers[header] = true

      for _, it in ipairs(list) do
        table.insert(options, string.format("  • %s  ->  [%s]", it.text, it.cmd))
      end
    end
  end

  vim.ui.select(options, { prompt = "Asistente Neovim" }, safe_callback(function(choice)
    if not choice then
      return
    end

    if choice == "Escribir comando..." then
      vim.ui.input({ prompt = "Asistente > " }, safe_callback(function(input)
        if input and trim(input) ~= "" then
          M.execute(input)
        end
      end))
      return
    end

    if headers[choice] then
      vim.notify("Elige una opcion debajo del encabezado", vim.log.levels.INFO)
      return
    end

    local command = choice:match("^%s*•%s*(.-)%s+%-%>%s+%[")
    if command then
      M.execute(trim(command))
    end
  end))
end

function M.command_complete(arglead)
  local out = {}
  local lead = (arglead or ""):lower()
  for _, s in ipairs(suggestions) do
    if s.text:find(lead, 1, true) == 1 or lead == "" then
      table.insert(out, s.text)
    end
  end
  return out
end

function M.setup()
  -- Cargar configuración del host actual
  local hosts = require("config.hosts")
  -- Hacer hosts disponible globalmente para resolve_host_path
  rawset(_G, "hosts", hosts)
  
  local host_key, current_host = hosts.get_current_host()
  
  -- Si hay un host configurado, usar sus favoritos y comandos
  if current_host then
    -- Reemplazar favoritos con los del host
    if current_host.favorites then
      for key, fav in pairs(current_host.favorites) do
        M.favorites[key] = fav
      end
    end
    
    -- Agregar comandos del host a las sugerencias
    if current_host.commands then
      -- Agregar al inicio de las sugerencias
      local host_commands = current_host.commands
      local existing = suggestions
      suggestions = {}
      
      -- Agregar comandos del host primero
      for _, cmd in ipairs(host_commands) do
        table.insert(suggestions, cmd)
      end
      
      -- Luego agregar los existentes (sin duplicados)
      for _, cmd in ipairs(existing) do
        local is_duplicate = false
        for _, host_cmd in ipairs(host_commands) do
          if host_cmd.text == cmd.text then
            is_duplicate = true
            break
          end
        end
        if not is_duplicate then
          table.insert(suggestions, cmd)
        end
      end
    end
    
    vim.g.nvim_host_key = host_key
    vim.g.nvim_host = current_host
  end

  -- Actualizar script_registry con rutas del host
  local function update_script_registry()
    local hosts = rawget(_G, "hosts")
    if not hosts then
      return
    end
    local _, host = hosts.get_current_host()
    if not host or not host.trading then
      return
    end
    
    for _, s in ipairs(script_registry) do
      if s.key == "trading-gui" then
        s.cwd = host.trading
        break
      end
    end
  end
  update_script_registry()

  -- Configurar menu de raton (RightClick) para reemplazar el del sistema
  pcall(function()
    vim.opt.mouse = "a"
    vim.opt.mousemodel = "popup_setpos"
    vim.cmd([[
      aunmenu PopUp
      anoremenu PopUp.Abrir\ OpenCode\ (cwd) :Do abrir opencode en cwd<CR>
      anoremenu PopUp.Buscar\ cambios\ OpenCode :Do buscar cambio opencode <C-r><C-w><CR>
      anoremenu PopUp.-Sep1- <Nop>
      anoremenu PopUp.Copiar "+y
      anoremenu PopUp.Pegar "+p
      anoremenu PopUp.-Sep2- <Nop>
      anoremenu PopUp.Asistente :Asistente<CR>
      anoremenu PopUp.Dashboard :lua Snacks.dashboard()<CR>
    ]])
  end)

  vim.api.nvim_set_hl(0, "AssistantOpencodeBar", {
    fg = "#1f1f1f",
    bg = "#98c379",
    bold = true,
  })
  vim.api.nvim_set_hl(0, "AssistantScriptBar", {
    fg = "#111111",
    bg = "#61afef",
    bold = true,
  })

  local group = vim.api.nvim_create_augroup("AssistantOpencodeLabels", { clear = true })
  vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter", "WinEnter" }, {
    group = group,
    callback = function()
      refresh_opencode_label_for_current_window()
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      local ok_prompt = pcall(function()
        if not should_prompt_save_workspace_on_exit() then
          return
        end

        local answer = vim.fn.confirm(
          "Guardar este espacio de trabajo como ultimo estado?",
          "&Guardar\n&No guardar",
          1
        )

        if answer == 1 then
          persist_workspace_state()
        end
      end)

      if not ok_prompt then
        pcall(persist_workspace_state)
      end
    end,
  })

  function M.open_project_picker()
    local choices = {
      { label = "Restaurar ultimo espacio", key = "restore" },
      { label = "Dynasif", key = "dynasif" },
      { label = "Trading", key = "trading" },
      { label = "Respaldos", key = "respaldos" },
      { label = "Proyectos", key = "proyectos" },
      { label = "Unidad Externa", key = "e" },
      { label = "Recursos", key = "recursos" },
      { label = "Dual (2 proyectos / 4 ventanas)", key = "dual" },
      { label = "Seguir sin abrir", key = "skip" },
    }

    local labels = {}
    for _, c in ipairs(choices) do
      table.insert(labels, c.label)
    end

    vim.ui.select(labels, { prompt = "Proyecto inicial" }, safe_callback(function(choice)
      if not choice or choice == "Seguir sin abrir" then
        return
      end

      for _, c in ipairs(choices) do
        if c.label == choice and c.key ~= "skip" then
          if c.key == "restore" then
            restore_last_workspace_state()
            return
          end

          if c.key == "dual" then
            open_dual_projects_picker()
            return
          end

          local fav = M.favorites[c.key]
          if not fav then
            vim.notify("Favorite not found: " .. tostring(c.key), vim.log.levels.WARN)
            return
          end
          open_workspace_two_panes(fav.path)
          return
        end
      end
    end))
  end

  vim.api.nvim_create_user_command("Asistente", function(opts)
    if trim(opts.args) == "" then
      M.open_menu()
    else
      M.execute(opts.args)
    end
  end, {
    nargs = "*",
    complete = function(arglead)
      return M.command_complete(arglead)
    end,
    desc = "Asistente de acciones para Neovim",
  })

  vim.api.nvim_create_user_command("Do", function(opts)
    if trim(opts.args) == "" then
      M.open_menu()
    else
      M.execute(opts.args)
    end
  end, {
    nargs = "*",
    complete = function(arglead)
      return M.command_complete(arglead)
    end,
    desc = "Shortcut de Asistente",
  })

  vim.cmd([[cnoreabbrev <expr> do ((getcmdtype() == ':' && getcmdline() ==# 'do') ? 'Do' : 'do')]])

  vim.api.nvim_create_user_command("Proyecto", function()
    M.open_project_picker()
  end, {
    nargs = 0,
    desc = "Abrir selector de proyecto inicial",
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if vim.fn.argc() ~= 0 or #vim.api.nvim_list_uis() == 0 then
        return
      end

      vim.schedule(function()
        local ok, err = pcall(M.open_project_picker)
        if not ok then
          vim.notify("Project picker failed: " .. tostring(err), vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

return M

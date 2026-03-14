-- This file contains custom key mappings for Neovim.

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local assistant = require("config.assistant")
local hosts = require("config.hosts")

-- Map Ctrl+b in insert mode to delete to the end of the word without leaving insert mode
vim.keymap.set("i", "<C-b>", "<C-o>de")

-- Map Ctrl+c to escape from other modes
vim.keymap.set({ "i", "n", "v" }, "<C-c>", [[<C-\><C-n>]])

-- Terminal: keep Esc Esc for OpenCode (it cancels actions there), exit mode elsewhere
vim.keymap.set("t", "<Esc><Esc>", function()
  local ft = vim.bo.filetype
  if ft == "opencode_terminal" or ft == "opencode_ask" then
    return "<Esc><Esc>"
  end
  return [[<C-\><C-n>]]
end, { expr = true, replace_keycodes = false, desc = "Exit terminal input mode (except OpenCode)" })

-- Reliable terminal exit key that never conflicts with OpenCode
vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { desc = "Exit terminal input mode" })

-- Screen Keys
vim.keymap.set({ "n" }, "<leader>uk", "<cmd>Screenkey<CR>")

----- Tmux Navigation ------
local nvim_tmux_nav = require("nvim-tmux-navigation")

local last_win = nil

vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    local current = vim.api.nvim_get_current_win()
    if current ~= last_win then
      vim.g._assistant_prev_win = last_win
      last_win = current
    end
  end,
})

local function swap_window_buffers(win_a, win_b)
  if not (win_a and win_b) then
    return false
  end
  if not (vim.api.nvim_win_is_valid(win_a) and vim.api.nvim_win_is_valid(win_b)) then
    return false
  end

  local buf_a = vim.api.nvim_win_get_buf(win_a)
  local buf_b = vim.api.nvim_win_get_buf(win_b)
  vim.api.nvim_win_set_buf(win_a, buf_b)
  vim.api.nvim_win_set_buf(win_b, buf_a)
  return true
end

local function smart_swap_to(direction)
  local current = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. direction)
  local target = vim.api.nvim_get_current_win()

  if target ~= current then
    if swap_window_buffers(current, target) then
      vim.api.nvim_set_current_win(target)
      return
    end
  end

  local normal_wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      table.insert(normal_wins, win)
    end
  end

  if #normal_wins == 2 then
    local reflow = { h = "H", j = "J", k = "K", l = "L" }
    local cmd = reflow[direction]
    if cmd then
      vim.api.nvim_set_current_win(current)
      vim.cmd("wincmd " .. cmd)
      return
    end
  end

  if vim.g._assistant_prev_win and vim.g._assistant_prev_win ~= current and vim.api.nvim_win_is_valid(vim.g._assistant_prev_win) then
    if swap_window_buffers(current, vim.g._assistant_prev_win) then
      vim.api.nvim_set_current_win(vim.g._assistant_prev_win)
      return
    end
  end

  vim.notify("No neighboring window to swap", vim.log.levels.INFO)
end

local function resize_current(direction)
  if direction == "left" then
    vim.cmd("vertical resize -4")
  elseif direction == "right" then
    vim.cmd("vertical resize +4")
  elseif direction == "up" then
    vim.cmd("resize +2")
  elseif direction == "down" then
    vim.cmd("resize -2")
  end
end

local function toggle_zoom_current_window()
  if vim.t._assistant_zoomed then
    local target = vim.t._assistant_zoom_win
    local restore = vim.t._assistant_zoom_restore

    if target and vim.api.nvim_win_is_valid(target) then
      pcall(vim.api.nvim_set_current_win, target)
    end
    if restore and restore ~= "" then
      vim.cmd(restore)
    end

    vim.t._assistant_zoomed = false
    vim.t._assistant_zoom_win = nil
    vim.t._assistant_zoom_restore = nil
    return
  end

  if #vim.api.nvim_tabpage_list_wins(0) <= 1 then
    vim.notify("Only one window is open", vim.log.levels.INFO)
    return
  end

  vim.t._assistant_zoom_win = vim.api.nvim_get_current_win()
  vim.t._assistant_zoom_restore = vim.fn.winrestcmd()
  vim.t._assistant_zoomed = true
  vim.cmd("wincmd |")
  vim.cmd("wincmd _")
end

vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft) -- Navigate to the left pane
vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown) -- Navigate to the bottom pane
vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp) -- Navigate to the top pane
vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight) -- Navigate to the right pane
vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive) -- Navigate to the last active pane
vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext) -- Navigate to the next pane

-- Arrow aliases for pane navigation (terminals usually can't detect Fn, so use Alt+Arrows)
vim.keymap.set("n", "<A-Left>", nvim_tmux_nav.NvimTmuxNavigateLeft, { desc = "Pane left" })
vim.keymap.set("n", "<A-Down>", nvim_tmux_nav.NvimTmuxNavigateDown, { desc = "Pane down" })
vim.keymap.set("n", "<A-Up>", nvim_tmux_nav.NvimTmuxNavigateUp, { desc = "Pane up" })
vim.keymap.set("n", "<A-Right>", nvim_tmux_nav.NvimTmuxNavigateRight, { desc = "Pane right" })

-- Move current window layout with Alt+Shift+Arrows
vim.keymap.set("n", "<A-S-Left>", function()
  smart_swap_to("h")
end, { desc = "Swap window left" })
vim.keymap.set("n", "<A-S-Down>", function()
  smart_swap_to("j")
end, { desc = "Swap window down" })
vim.keymap.set("n", "<A-S-Up>", function()
  smart_swap_to("k")
end, { desc = "Swap window up" })
vim.keymap.set("n", "<A-S-Right>", function()
  smart_swap_to("l")
end, { desc = "Swap window right" })

-- Some terminals collapse Alt+Shift+Arrow. Add robust fallbacks.
vim.keymap.set("n", "<C-A-Left>", function()
  smart_swap_to("h")
end, { desc = "Swap window left" })
vim.keymap.set("n", "<C-A-Down>", function()
  smart_swap_to("j")
end, { desc = "Swap window down" })
vim.keymap.set("n", "<C-A-Up>", function()
  smart_swap_to("k")
end, { desc = "Swap window up" })
vim.keymap.set("n", "<C-A-Right>", function()
  smart_swap_to("l")
end, { desc = "Swap window right" })

vim.keymap.set("n", "<leader>wh", function()
  smart_swap_to("h")
end, { desc = "Swap window left" })
vim.keymap.set("n", "<leader>wj", function()
  smart_swap_to("j")
end, { desc = "Swap window down" })
vim.keymap.set("n", "<leader>wk", function()
  smart_swap_to("k")
end, { desc = "Swap window up" })
vim.keymap.set("n", "<leader>wl", function()
  smart_swap_to("l")
end, { desc = "Swap window right" })

-- Fallback move aliases (more reliable in terminals)
vim.keymap.set("n", "<A-H>", function()
  smart_swap_to("h")
end, { desc = "Swap window left" })
vim.keymap.set("n", "<A-J>", function()
  smart_swap_to("j")
end, { desc = "Swap window down" })
vim.keymap.set("n", "<A-K>", function()
  smart_swap_to("k")
end, { desc = "Swap window up" })
vim.keymap.set("n", "<A-L>", function()
  smart_swap_to("l")
end, { desc = "Swap window right" })

-- Resize current window with Shift+Arrows
vim.keymap.set("n", "<S-Left>", function()
  resize_current("left")
end, { desc = "Resize window narrower" })
vim.keymap.set("n", "<S-Right>", function()
  resize_current("right")
end, { desc = "Resize window wider" })
vim.keymap.set("n", "<S-Up>", function()
  resize_current("up")
end, { desc = "Resize window taller" })
vim.keymap.set("n", "<S-Down>", function()
  resize_current("down")
end, { desc = "Resize window shorter" })

-- Fallback for terminals that don't expose Shift+Arrows
vim.keymap.set("n", "<C-S-Left>", function()
  resize_current("left")
end, { desc = "Resize window narrower" })
vim.keymap.set("n", "<C-S-Right>", function()
  resize_current("right")
end, { desc = "Resize window wider" })
vim.keymap.set("n", "<C-S-Up>", function()
  resize_current("up")
end, { desc = "Resize window taller" })
vim.keymap.set("n", "<C-S-Down>", function()
  resize_current("down")
end, { desc = "Resize window shorter" })

-- Maximize/restore current window
vim.keymap.set("n", "<leader><CR>", toggle_zoom_current_window, { desc = "Toggle maximize current window" })

----- OBSIDIAN -----
vim.keymap.set("n", "<leader>nc", "<cmd>Obsidian check<CR>", { desc = "Obsidian Check Checkbox" })
vim.keymap.set("n", "<leader>nt", "<cmd>Obsidian template<CR>", { desc = "Insert Obsidian Template" })
vim.keymap.set("n", "<leader>no", "<cmd>Obsidian open<CR>", { desc = "Open in Obsidian App" })
vim.keymap.set("n", "<leader>nb", "<cmd>Obsidian backlinks<CR>", { desc = "Show Obsidian Backlinks" })
vim.keymap.set("n", "<leader>nl", "<cmd>Obsidian links<CR>", { desc = "Show Obsidian Links" })
vim.keymap.set("n", "<leader>nn", "<cmd>Obsidian new<CR>", { desc = "Create New Note" })
vim.keymap.set("n", "<leader>ns", "<cmd>Obsidian search<CR>", { desc = "Search Obsidian" })
vim.keymap.set("n", "<leader>nq", "<cmd>Obsidian quick-switch<CR>", { desc = "Quick Switch" })

----- OIL -----
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "--", "<CMD>Oil<CR>", { desc = "Open parent directory (double)" })

local function open_file_in_float(path)
  local file = vim.fn.fnamemodify(path, ":p")
  if vim.fn.filereadable(file) == 0 then
    vim.notify("File not found: " .. file, vim.log.levels.WARN)
    return
  end

  local buf = vim.fn.bufadd(file)
  vim.fn.bufload(buf)

  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.8)
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
  })

  vim.wo[win].number = true
  vim.wo[win].relativenumber = false
  vim.wo[win].winbar = "%#AssistantOpencodeBar# Float: %f %#WinBar#"
end

local function pick_file_and_open_float()
  local cwd = vim.fn.getcwd()
  local lines = vim.fn.systemlist({ "fd", "-t", "f", ".", cwd })
  if vim.v.shell_error ~= 0 or #lines == 0 then
    vim.notify("No files found from cwd: " .. cwd, vim.log.levels.WARN)
    return
  end

  table.sort(lines)
  vim.ui.select(lines, { prompt = "Pick file for floating window" }, function(choice)
    if not choice then
      return
    end
    open_file_in_float(choice)
  end)
end

vim.keymap.set("n", "<leader>fF", pick_file_and_open_float, { desc = "Find file in floating window" })

local function list_subdirs(path)
  local ok, entries = pcall(vim.fn.readdir, path)
  if not ok or not entries then
    return {}
  end

  local out = {}
  for _, name in ipairs(entries) do
    if type(name) == "string" and name ~= "" then
      local full = path:gsub("/+$", "") .. "/" .. name
      if vim.fn.isdirectory(full) == 1 then
        table.insert(out, (full:gsub("\\", "/")))
      end
    end
  end
  table.sort(out)
  return out
end

local function pick_base_dir(callback)
  -- Obtener rutas del host actual
  local _, host = hosts.get_current_host()
  local base_drive = host and host.base or "D:"
  
  local favs = {
    { label = "cwd actual", path = vim.fn.getcwd() },
    { label = "Dynasif", path = host and host.dynasif or "D:/Pintulac/01_PRODUCCION/dynasif" },
    { label = "Trading", path = host and host.trading or "D:/Proyectos/Activos/trading/TradingManager" },
    { label = "Respaldos", path = host and host.respaldos or "D:/Pintulac/06_RESPALDOS/Funcionalidades/Respaldos-Funcionalidades/Respaldos" },
    { label = base_drive .. " (elegir carpeta)", path = base_drive .. "/" },
  }

  local labels = {}
  for _, f in ipairs(favs) do
    table.insert(labels, f.label)
  end

  vim.ui.select(labels, { prompt = "Origen de archivos" }, function(choice)
    local ok_cb, err_cb = pcall(function()
    if not choice then
      return
    end

    local selected = nil
    for _, f in ipairs(favs) do
      if f.label == choice then
        selected = f
        break
      end
    end
    if not selected then
      return
    end

    if selected.label == base_drive .. " (elegir carpeta)" then
      local dirs = list_subdirs(base_drive .. "/")
      if #dirs == 0 then
        vim.notify("No hay carpetas en " .. base_drive, vim.log.levels.WARN)
        return
      end
      vim.ui.select(dirs, { prompt = base_drive .. " -> elegir carpeta" }, function(dir)
        if dir then
          callback(dir)
        end
      end)
      return
    end

    callback(selected.path)
    end)
    if not ok_cb then
      vim.notify("Base dir picker error: " .. tostring(err_cb), vim.log.levels.ERROR)
    end
  end)
end

local function quick_pick_file_in_new_window()
  local ok, err = pcall(function()
    pick_base_dir(function(base)
      if vim.fn.isdirectory(base) == 0 then
        vim.notify("Ruta invalida: " .. base, vim.log.levels.WARN)
        return
      end

      local files = vim.fn.systemlist({ "fd", "-t", "f", ".", base })
      if vim.v.shell_error ~= 0 or #files == 0 then
        vim.notify("No files found in: " .. base, vim.log.levels.WARN)
        return
      end

      table.sort(files)
      local base_norm = base:gsub("\\", "/"):gsub("/+$", "")
      local labels = {}
      for _, f in ipairs(files) do
        if type(f) == "string" and f ~= "" then
          local f_norm = f:gsub("\\", "/")
          local rel = f_norm
          if f_norm:sub(1, #base_norm):lower() == base_norm:lower() then
            rel = f_norm:sub(#base_norm + 1):gsub("^/", "")
          end
          if rel and rel ~= "" then
            table.insert(labels, rel)
          end
        end
      end

      if #labels == 0 then
        vim.notify("No files found in: " .. base, vim.log.levels.WARN)
        return
      end

      vim.ui.select(labels, { prompt = "Archivo -> nueva ventana" }, function(rel)
        if not rel then
          return
        end

        local full = base:gsub("/+$", "") .. "/" .. rel
        vim.cmd("botright vsplit " .. vim.fn.fnameescape(full))
      end)
    end)
  end)

  if not ok then
    vim.notify("Quick picker error: " .. tostring(err), vim.log.levels.ERROR)
  end
end

vim.keymap.set("n", "<leader>fv", quick_pick_file_in_new_window, { desc = "Quick file in new window" })

----- FAVORITES -----
vim.keymap.set("n", "<leader>jd", function()
  assistant.open_favorite("d")
end, { desc = "Favorite: D drive" })

vim.keymap.set("n", "<leader>jm", function()
  assistant.open_favorite("documents")
end, { desc = "Favorite: Documents" })

vim.keymap.set("n", "<leader>jp", function()
  assistant.open_favorite("proyectos")
end, { desc = "Favorite: Projects" })

vim.keymap.set("n", "<leader>jt", function()
  assistant.open_favorite("trading")
end, { desc = "Favorite: Trading" })

vim.keymap.set("n", "<leader>jy", function()
  assistant.open_favorite("dynasif")
end, { desc = "Favorite: Dynasif" })

vim.keymap.set("n", "<leader>jr", function()
  assistant.open_favorite("respaldos")
end, { desc = "Favorite: Respaldos" })

vim.keymap.set("n", "<leader>je", function()
  assistant.open_favorite("e")
end, { desc = "Favorite: Unidad Externa" })

vim.keymap.set("n", "<leader>jz", function()
  assistant.open_favorite("recursos")
end, { desc = "Favorite: Recursos" })

vim.keymap.set("n", "<leader>ah", assistant.open_menu, { desc = "Asistente menu" })
vim.keymap.set("n", "<leader>ap", "<cmd>Proyecto<CR>", { desc = "Selector de proyecto" })
vim.keymap.set("n", "<leader>pp", "<cmd>Proyecto<CR>", { desc = "Project picker" })
vim.keymap.set("n", "<leader>?", assistant.open_menu, { desc = "Asistente menu" })
vim.keymap.set("n", "<leader>ss", "<cmd>lua Snacks.dashboard()<CR>", { desc = "Snoopy dashboard" })

-- Delete all buffers but the current one
vim.keymap.set(
  "n",
  "<leader>bq",
  '<Esc>:%bdelete|edit #|normal`"<Return>',
  { desc = "Delete other buffers but the current one" }
)

-- Disable key mappings in insert mode
vim.api.nvim_set_keymap("i", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-k>", "<Nop>", { noremap = true, silent = true })

-- Disable key mappings in normal mode
vim.api.nvim_set_keymap("n", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-k>", "<Nop>", { noremap = true, silent = true })

-- Disable key mappings in visual block mode
vim.api.nvim_set_keymap("x", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<A-k>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "J", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "K", "<Nop>", { noremap = true, silent = true })

-- Redefine Ctrl+s to save with the custom function
vim.api.nvim_set_keymap("n", "<C-s>", ":lua SaveFile()<CR>", { noremap = true, silent = true })

-- Grep keybinding for visual mode - search selected text
vim.keymap.set("v", "<leader>sg", function()
  -- Get the selected text
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    return
  end

  -- Handle single line selection
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    -- Handle multi-line selection
    lines[1] = string.sub(lines[1], start_pos[3])
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  local selected_text = table.concat(lines, "\n")

  -- Escape special characters for grep
  selected_text = vim.fn.escape(selected_text, "\\.*[]^$()+?{}")

  -- Use the selected text for grep
  if pcall(require, "snacks") then
    require("snacks").picker.grep({ search = selected_text })
  elseif pcall(require, "fzf-lua") then
    require("fzf-lua").live_grep({ search = selected_text })
  else
    vim.notify("No grep picker available", vim.log.levels.ERROR)
  end
end, { desc = "Grep Selected Text" })

-- Grep keybinding for visual mode with G - search selected text at root level
vim.keymap.set("v", "<leader>sG", function()
  -- Get git root or fallback to cwd
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  local root = vim.v.shell_error == 0 and git_root ~= "" and git_root or vim.fn.getcwd()

  -- Get the selected text
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    return
  end

  -- Handle single line selection
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    -- Handle multi-line selection
    lines[1] = string.sub(lines[1], start_pos[3])
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  local selected_text = table.concat(lines, "\n")

  -- Escape special characters for grep
  selected_text = vim.fn.escape(selected_text, "\\.*[]^$()+?{}")

  -- Use the selected text for grep at root level
  if pcall(require, "snacks") then
    require("snacks").picker.grep({ search = selected_text, cwd = root })
  elseif pcall(require, "fzf-lua") then
    require("fzf-lua").live_grep({ search = selected_text, cwd = root })
  else
    vim.notify("No grep picker available", vim.log.levels.ERROR)
  end
end, { desc = "Grep Selected Text (Root Dir)" })

-- Delete all marks
vim.keymap.set("n", "<leader>md", function()
  vim.cmd("delmarks!")
  vim.cmd("delmarks A-Z0-9")
  vim.notify("All marks deleted")
end, { desc = "Delete all marks" })

-- Custom save function
function SaveFile()
  -- Check if a buffer with a file is open
  if vim.fn.empty(vim.fn.expand("%:t")) == 1 then
    vim.notify("No file to save", vim.log.levels.WARN)
    return
  end

  local filename = vim.fn.expand("%:t") -- Get only the filename
  local success, err = pcall(function()
    vim.cmd("silent! write") -- Try to save the file without showing the default message
  end)

  if success then
    vim.notify(filename .. " Saved!") -- Show only the custom message if successful
  else
    vim.notify("Error: " .. err, vim.log.levels.ERROR) -- Show the error message if it fails
  end
end

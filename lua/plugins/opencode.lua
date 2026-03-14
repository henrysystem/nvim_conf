local clipboard_image_batch = {}
local session_clipboard_images = {}
local session_clipboard_image_set = {}
local image_store_dir = "D:/Recursos/opencode_img"
local max_stored_images = 10

local function normalize_path(path)
  return (path or ""):gsub("\\", "/"):gsub("/+$", "")
end

local function ensure_image_store_dir()
  if vim.fn.isdirectory(image_store_dir) == 0 then
    vim.fn.mkdir(image_store_dir, "p")
  end
end

local function list_stored_images()
  ensure_image_store_dir()
  local dir = normalize_path(vim.fn.fnamemodify(image_store_dir, ":p"))
  local files = vim.fn.globpath(dir, "opencode-clip-*.png", false, true)

  table.sort(files, function(a, b)
    local sa = vim.uv.fs_stat(a)
    local sb = vim.uv.fs_stat(b)
    local ma = sa and sa.mtime and sa.mtime.sec or 0
    local mb = sb and sb.mtime and sb.mtime.sec or 0
    if ma == mb then
      return a > b
    end
    return ma > mb
  end)

  return files
end

local function prune_stored_images()
  local files = list_stored_images()
  if #files <= max_stored_images then
    return
  end

  for i = max_stored_images + 1, #files do
    pcall(vim.fn.delete, files[i])
  end
end

local function remember_session_image(path)
  if session_clipboard_image_set[path] then
    return
  end
  session_clipboard_image_set[path] = true
  table.insert(session_clipboard_images, path)
end

local function capture_clipboard_image()
  ensure_image_store_dir()
  local target_dir = normalize_path(vim.fn.fnamemodify(image_store_dir, ":p"))
  local cmd = {
    "powershell",
    "-NoProfile",
    "-Sta",
    "-Command",
    table.concat({
      "Add-Type -AssemblyName System.Windows.Forms;",
      "Add-Type -AssemblyName System.Drawing;",
      "if ([Windows.Forms.Clipboard]::ContainsImage()) {",
      "  $img = [Windows.Forms.Clipboard]::GetImage();",
      "  $targetDir = '" .. target_dir:gsub("'", "''") .. "';",
      "  if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }",
      "  $path = Join-Path $targetDir ('opencode-clip-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '.png');",
      "  $img.Save($path, [System.Drawing.Imaging.ImageFormat]::Png);",
      "  Write-Output $path;",
      "}",
    }, " "),
  }

  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Could not read clipboard image", vim.log.levels.ERROR)
    return nil
  end

  local path = vim.trim(out)
  if path == "" then
    vim.notify("No image found in clipboard", vim.log.levels.WARN)
    return nil
  end

  prune_stored_images()

  return path
end

local function image_file_ref(path)
  local absolute = vim.fn.fnamemodify(path or "", ":p")
  local normalized = vim.trim(absolute:gsub("\\", "/"))
  return normalized
end

local function opencode_add_clipboard_image()
  local path = capture_clipboard_image()
  if not path then
    return
  end

  remember_session_image(path)
  table.insert(clipboard_image_batch, path)
  vim.notify(string.format("Added image %d to OpenCode batch", #clipboard_image_batch), vim.log.levels.INFO)
end

local function opencode_send_clipboard_batch()
  if #clipboard_image_batch == 0 then
    vim.notify("OpenCode image batch is empty", vim.log.levels.WARN)
    return
  end

  local refs = {}
  for _, path in ipairs(clipboard_image_batch) do
    table.insert(refs, image_file_ref(path))
  end

  require("opencode").ask(table.concat(refs, " ") .. " ", { submit = false })
  vim.notify(string.format("Loaded %d images into OpenCode prompt", #clipboard_image_batch), vim.log.levels.INFO)
  clipboard_image_batch = {}
end

local function opencode_clear_clipboard_batch()
  clipboard_image_batch = {}
  vim.notify("Cleared OpenCode image batch", vim.log.levels.INFO)
end

local function opencode_single_clipboard_image()
  local path = capture_clipboard_image()
  if not path then
    return
  end

  remember_session_image(path)
  require("opencode").ask(image_file_ref(path) .. " ", { submit = false })
end

local function find_opencode_target()
  local ft = vim.bo.filetype
  if ft == "opencode_terminal" or ft == "opencode_ask" then
    return { win = vim.api.nvim_get_current_win(), buf = vim.api.nvim_get_current_buf(), ft = ft }
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local wft = vim.bo[buf].filetype
    if wft == "opencode_terminal" or wft == "opencode_ask" then
      return { win = win, buf = buf, ft = wft }
    end
  end

  return nil
end

local function insert_text_in_opencode_target(target, text, submit)
  if target.ft == "opencode_terminal" then
    local job = vim.b[target.buf].terminal_job_id
    if not job or job <= 0 then
      vim.notify("OpenCode terminal job is not available", vim.log.levels.ERROR)
      return false
    end
    if submit then
      vim.fn.chansend(job, text)
      vim.defer_fn(function()
        local current_job = vim.b[target.buf] and vim.b[target.buf].terminal_job_id or nil
        if current_job and current_job == job then
          vim.fn.chansend(job, "\r")
        end
      end, 140)
    else
      vim.fn.chansend(job, text)
    end
    return true
  end

  if not vim.api.nvim_buf_is_valid(target.buf) or not vim.api.nvim_buf_get_option(target.buf, "modifiable") then
    vim.notify("OpenCode input buffer is not editable", vim.log.levels.WARN)
    return false
  end

  local current_win = vim.api.nvim_get_current_win()
  pcall(vim.api.nvim_set_current_win, target.win)

  local cursor = vim.api.nvim_win_get_cursor(target.win)
  local row = cursor[1] - 1
  local col = cursor[2]
  local pieces = vim.split(text, "\n", { plain = true })
  vim.api.nvim_buf_set_text(target.buf, row, col, row, col, pieces)

  local end_row = cursor[1] + #pieces - 1
  local end_col = (#pieces == 1) and (col + #pieces[1]) or #pieces[#pieces]
  pcall(vim.api.nvim_win_set_cursor, target.win, { end_row, end_col })

  if current_win ~= target.win and vim.api.nvim_win_is_valid(current_win) then
    pcall(vim.api.nvim_set_current_win, current_win)
  end

  if submit then
    pcall(function()
      require("opencode").command("prompt.submit")
    end)
  end

  return true
end

local function opencode_show_shortcuts_help()
  local lines = {
    "OpenCode quick help",
    "",
    "Internal shortcuts (inside OpenCode):",
    "- ctrl+p: command list",
    "- tab / shift+tab: cycle agents",
    "- ctrl+t: cycle variants",
    "- esc: interrupt current run",
    "",
    "Useful slash commands:",
    "- /session",
    "- /model",
    "- /agent",
    "- /review",
    "",
    "Neovim helpers:",
    "- <leader>of: default !c (claude->deep)",
    "  - !c pregunta  => Claude rapido + OpenCode profundo",
    "  - !C pregunta  => Claude Opus 4.6 (turbo)",
    "  - !g pregunta  => Gemini 2.5 Flash (estable)",
    "  - !G pregunta  => Gemini 2.5 Pro (fallback a Flash)",
    "  - !d pregunta  => directo a OpenCode",
    "- <leader>oj: send clipboard image now",
    "- <leader>oa: send image batch now",
    "- <leader>ov: pick 1-10 recent images and send (newest first)",
    "- <leader>oc: add clipboard image to batch",
    "- <leader>ox: clear image batch",
    "- <leader>oi: ask",
    "- <leader>os: picker (prompts/commands)",
  }
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "opencode" })
end

local function opencode_send_single_image_fast()
  local path = capture_clipboard_image()
  if not path then
    return
  end

  remember_session_image(path)
  local target = find_opencode_target()
  if not target then
    vim.notify("No active OpenCode window found. Open one first.", vim.log.levels.WARN)
    return
  end

  local ok = insert_text_in_opencode_target(target, image_file_ref(path) .. " ", true)
  if ok then
    vim.notify("Sent clipboard image to OpenCode", vim.log.levels.INFO)
  end
end

local function opencode_send_batch_fast()
  if #clipboard_image_batch == 0 then
    vim.notify("OpenCode image batch is empty", vim.log.levels.WARN)
    return
  end

  local refs = {}
  for _, path in ipairs(clipboard_image_batch) do
    table.insert(refs, image_file_ref(path))
  end

  local target = find_opencode_target()
  if not target then
    vim.notify("No active OpenCode window found. Open one first.", vim.log.levels.WARN)
    return
  end

  local ok = insert_text_in_opencode_target(target, table.concat(refs, " ") .. " ", true)
  if ok then
    clipboard_image_batch = {}
    vim.notify(string.format("Sent %d batch images to OpenCode", #refs), vim.log.levels.INFO)
  end
end

local function recent_clipboard_images(limit)
  local out = {}
  local max_items = limit or max_stored_images
  local files = list_stored_images()

  for i = 1, math.min(#files, max_items) do
    table.insert(out, files[i])
  end

  return out
end

local function select_recent_images(limit, done)
  local recent = recent_clipboard_images(limit or 5)
  if #recent == 0 then
    -- Fallback: capture current clipboard image so picker works even
    -- if user copied an image but did not run add/send before.
    local path = capture_clipboard_image()
    if path then
      remember_session_image(path)
      recent = recent_clipboard_images(limit or 5)
    end

    if #recent == 0 then
      vim.notify("No recent clipboard images found", vim.log.levels.WARN)
      return
    end
  end

  local selected = {}

  local function render_items()
    local items = {}
    for i, path in ipairs(recent) do
      local mark = selected[path] and "[x]" or "[ ]"
      local name = vim.fn.fnamemodify(path, ":t")
      local stat = vim.uv.fs_stat(path)
      local stamp = stat and stat.mtime and os.date("%Y-%m-%d %H:%M:%S", stat.mtime.sec) or "sin fecha"
      local latest = (i == 1) and " [ULTIMA]" or ""
      table.insert(items, {
        kind = "image",
        path = path,
        label = string.format("%s %d) %s (%s)%s", mark, i, name, stamp, latest),
      })
    end
    table.insert(items, { kind = "send", label = "Enviar seleccion" })
    table.insert(items, { kind = "cancel", label = "Cancelar" })
    return items
  end

  local function pick_loop()
    local items = render_items()
    vim.ui.select(items, {
      prompt = "Imagenes recientes (marca y envia)",
      format_item = function(item)
        return item.label
      end,
    }, function(choice)
      if not choice or choice.kind == "cancel" then
        return
      end

      if choice.kind == "image" then
        selected[choice.path] = not selected[choice.path]
        pick_loop()
        return
      end

      local picked = {}
      for _, path in ipairs(recent) do
        if selected[path] then
          table.insert(picked, path)
        end
      end

      if #picked == 0 then
        vim.notify("No images selected", vim.log.levels.WARN)
        pick_loop()
        return
      end

      done(picked)
    end)
  end

  pick_loop()
end

local function opencode_send_recent_picker()
  local target = find_opencode_target()
  if not target then
    vim.notify("No active OpenCode window found. Open one first.", vim.log.levels.WARN)
    return
  end

  select_recent_images(max_stored_images, function(paths)
    local refs = {}
    for _, path in ipairs(paths) do
      table.insert(refs, image_file_ref(path))
    end
    local ok = insert_text_in_opencode_target(target, table.concat(refs, " ") .. " ", true)
    if ok then
      vim.notify(string.format("Sent %d selected images to OpenCode", #refs), vim.log.levels.INFO)
    end
  end)
end

local function parse_route_tag(input)
  local text = vim.trim(input or "")
  local tag, rest = text:match("^!(%a)%s+(.+)$")
  if tag and rest then
    if tag == "C" then
      return "o", vim.trim(rest), true
    end
    if tag == "G" then
      return "p", vim.trim(rest), true
    end

    local lowered = tag:lower()
    if lowered == "c" or lowered == "g" or lowered == "x" or lowered == "r" or lowered == "d" then
      return lowered, vim.trim(rest), true
    end
  end
  return nil, text, false
end

local function infer_default_mode(prompt)
  local p = (prompt or ""):lower()

  if p:find("error", 1, true)
      or p:find("bug", 1, true)
      or p:find("traceback", 1, true)
      or p:find("falla", 1, true)
      or p:find("correg", 1, true)
      or p:find("fix", 1, true)
      or p:find("debug", 1, true) then
    return "x"
  end

  if p:find("investiga", 1, true)
      or p:find("research", 1, true)
      or p:find("profund", 1, true)
      or p:find("compara", 1, true)
      or p:find("analiza", 1, true)
      or p:find("benchmark", 1, true) then
    return "g"
  end

  if p:find("informe", 1, true)
      or p:find("reporte", 1, true)
      or p:find("resumen final", 1, true) then
    return "r"
  end

  return "c"
end

local route_models = {
  c = "anthropic/claude-sonnet-4-6",
  g = "google/gemini-2.5-flash",
  p = "google/gemini-2.5-pro",
  x = "openai/gpt-5.3-codex",
  r = "openai/gpt-5.3-codex",
  o = "anthropic/claude-opus-4-6",
}

local route_labels = {
  c = "coding (Claude)",
  g = "research (Gemini Flash)",
  p = "research pro (Gemini Pro)",
  x = "fix/debug (Codex)",
  r = "final report (Codex)",
  o = "turbo coding (Opus)",
  d = "direct (no routing)",
}

local function switch_model_and_submit(target, model, prompt)
  if target.ft == "opencode_terminal" then
    local job = vim.b[target.buf].terminal_job_id
    if not job or job <= 0 then
      vim.notify("OpenCode terminal job is not available", vim.log.levels.ERROR)
      return false
    end

    vim.fn.chansend(job, "/model " .. model .. "\r")
    vim.defer_fn(function()
      if vim.fn.jobwait({ job }, 0)[1] == -1 then
        vim.fn.chansend(job, prompt .. " \r")
      end
    end, 220)
    return true
  end

  local payload = string.format("Usa el modelo %s para esta tarea.\n\n%s", model, prompt)
  return insert_text_in_opencode_target(target, payload .. " ", true)
end

local function resolve_route_chain(mode)
  if mode == "c" then
    return { "c", "g", "x" }
  end
  if mode == "g" then
    return { "g", "x" }
  end
  if mode == "p" then
    return { "p", "g", "x" }
  end
  if mode == "x" then
    return { "x", "g" }
  end
  if mode == "r" then
    return { "r", "x", "g" }
  end
  if mode == "o" then
    return { "o", "c", "g", "x" }
  end
  return { mode }
end

local function try_route_chain(target, chain, prompt, forced)
  local function step(i)
    local mode = chain[i]
    if not mode then
      local ok = insert_text_in_opencode_target(target, prompt .. " ", true)
      if ok then
        vim.notify("All routed models failed -> sent prompt direct", vim.log.levels.WARN)
      end
      return ok
    end

    local model = route_models[mode]
    if not model then
      return step(i + 1)
    end

    local ok = switch_model_and_submit(target, model, prompt)
    if ok then
      local prefix = forced and "Route (forced): " or "Route (auto): "
      vim.notify(prefix .. route_labels[mode] .. " | model: " .. model, vim.log.levels.INFO)
      return true
    end

    vim.notify("Model route failed: " .. model .. " -> trying next", vim.log.levels.WARN)
    return step(i + 1)
  end

  return step(1)
end

local function route_prompt_to_opencode(input)
  local target = find_opencode_target()
  if not target then
    vim.notify("No active OpenCode window found. Open one first.", vim.log.levels.WARN)
    return false
  end

  local tagged_mode, prompt, forced = parse_route_tag(input)
  if prompt == "" then
    return false
  end

  local mode = tagged_mode or infer_default_mode(prompt)

  if mode == "d" then
    local ok = insert_text_in_opencode_target(target, prompt .. " ", true)
    if ok then
      vim.notify("Route: " .. route_labels.d, vim.log.levels.INFO)
    end
    return ok
  end

  local model = route_models[mode]
  if not model then
    return insert_text_in_opencode_target(target, prompt .. " ", true)
  end

  local chain = resolve_route_chain(mode)
  return try_route_chain(target, chain, prompt, forced)
end

local function opencode_compose_with_floating_input()
  if vim.api.nvim_get_mode().mode:sub(1, 1) == "t" then
    vim.cmd("stopinsert")
  end

  vim.ui.input({ prompt = "OpenCode > " }, function(input)
    local text = vim.trim(input or "")
    if text == "" then
      return
    end

    route_prompt_to_opencode(text)
  end)
end

return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  keys = {
    {
      "<leader>o",
      nil,
      desc = "OpenCode",
    },
    {
      "<leader>oo",
      function()
        require("opencode").toggle()
      end,
      mode = { "n" },
      desc = "Toggle OpenCode",
    },
    {
      "<leader>os",
      function()
        require("opencode").select({ submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode select",
    },
    {
      "<leader>oi",
      function()
        require("opencode").ask("", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask",
    },
    {
      "<leader>of",
      opencode_compose_with_floating_input,
      mode = { "n", "x", "t" },
      desc = "OpenCode compose and submit",
    },
    {
      "<leader>oh",
      opencode_show_shortcuts_help,
      mode = { "n", "x", "t" },
      desc = "OpenCode shortcuts help",
    },
    {
      "<leader>oI",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask with context",
    },
    {
      "<leader>ob",
      function()
        require("opencode").ask("@file ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask about buffer",
    },
    {
      "<leader>oC",
      opencode_add_clipboard_image,
      mode = { "n", "t" },
      desc = "OpenCode add clipboard image",
      nowait = true,
    },
    {
      "<leader>oc",
      opencode_add_clipboard_image,
      mode = { "n", "t" },
      desc = "OpenCode add clipboard image",
      nowait = true,
    },
    {
      "<leader>oA",
      opencode_send_batch_fast,
      mode = { "n", "t" },
      desc = "OpenCode send image batch",
      nowait = true,
    },
    {
      "<leader>oa",
      opencode_send_batch_fast,
      mode = { "n", "t" },
      desc = "OpenCode send image batch",
      nowait = true,
    },
    {
      "<leader>oV",
      opencode_send_recent_picker,
      mode = { "n", "t" },
      desc = "OpenCode pick recent images",
      nowait = true,
    },
    {
      "<leader>ov",
      opencode_send_recent_picker,
      mode = { "n", "t" },
      desc = "OpenCode pick recent images",
      nowait = true,
    },
    {
      "<leader>oS",
      opencode_send_single_image_fast,
      mode = { "n", "t" },
      desc = "OpenCode single clipboard image",
      nowait = true,
    },
    {
      "<leader>oj",
      opencode_send_single_image_fast,
      mode = { "n", "t" },
      desc = "OpenCode single clipboard image",
      nowait = true,
    },
    {
      "<leader>oX",
      opencode_clear_clipboard_batch,
      mode = { "n", "t" },
      desc = "OpenCode clear image batch",
      nowait = true,
    },
    {
      "<leader>ox",
      opencode_clear_clipboard_batch,
      mode = { "n", "t" },
      desc = "OpenCode clear image batch",
      nowait = true,
    },
    {
      "<leader>op",
      function()
        require("opencode").prompt("@this", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode prompt",
    },
    -- Built-in prompts
    {
      "<leader>ope",
      function()
        require("opencode").prompt("explain", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode explain",
    },
    {
      "<leader>opf",
      function()
        require("opencode").prompt("fix", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode fix",
    },
    {
      "<leader>opd",
      function()
        require("opencode").prompt("diagnose", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode diagnose",
    },
    {
      "<leader>opr",
      function()
        require("opencode").prompt("review", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode review",
    },
    {
      "<leader>opt",
      function()
        require("opencode").prompt("test", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode test",
    },
    {
      "<leader>opo",
      function()
        require("opencode").prompt("optimize", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode optimize",
    },
  },
  config = function()
    local function style_opencode_windows(buf)
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if vim.api.nvim_win_is_valid(win) then
          vim.wo[win].winhl = "Normal:NormalFloat,NormalNC:NormalFloat,SignColumn:NormalFloat,EndOfBuffer:NormalFloat"
          vim.wo[win].winblend = 24
        end
      end
    end

    vim.g.opencode_opts = {
      provider = {
        snacks = {
          win = {
            position = "right",
            width = 0.6,
            enter = true,
            border = "none",
          },
        },
      },
    }
    vim.o.autoread = true

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "opencode_terminal", "opencode_ask" },
      callback = function(args)
        style_opencode_windows(args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        local keep_dir = normalize_path(vim.fn.fnamemodify(image_store_dir, ":p")):lower()
        for _, path in ipairs(session_clipboard_images) do
          local full = normalize_path(vim.fn.fnamemodify(path, ":p")):lower()
          if not vim.startswith(full, keep_dir .. "/") then
            pcall(vim.fn.delete, path)
          end
        end
      end,
    })

    _G.OpencodeRoutePrompt = route_prompt_to_opencode
  end,
}

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

if vim.fn.has("win32") == 1 then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if #vim.api.nvim_list_uis() == 0 then
        return
      end

      local pid = vim.fn.getpid()
      local script = table.concat({
        "Add-Type @'",
        "using System;",
        "using System.Runtime.InteropServices;",
        "public static class W {",
        "  [DllImport(\"user32.dll\")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);",
        "}",
        "'@;",
        "$pidNvim = " .. pid .. ";",
        "$proc = Get-CimInstance Win32_Process -Filter \"ProcessId=$pidNvim\";",
        "$target = $null;",
        "if ($proc -and $proc.ParentProcessId) { $target = Get-Process -Id $proc.ParentProcessId -ErrorAction SilentlyContinue }",
        "if (-not $target) { $target = Get-Process -Id $pidNvim -ErrorAction SilentlyContinue }",
        "if ($target -and $target.MainWindowHandle -ne 0) { [W]::ShowWindowAsync($target.MainWindowHandle, 3) | Out-Null }",
      }, " ")

      vim.defer_fn(function()
        pcall(vim.system, { "powershell", "-NoProfile", "-WindowStyle", "Hidden", "-Command", script }, { detach = true })
      end, 120)
    end,
  })
end

if not vim.g._notify_logger_installed then
  vim.g._notify_logger_installed = true

  local notify_log = vim.fn.stdpath("data") .. "/notifications.log"
  local original_notify = vim.notify

  local level_name = {
    [vim.log.levels.TRACE] = "TRACE",
    [vim.log.levels.DEBUG] = "DEBUG",
    [vim.log.levels.INFO] = "INFO",
    [vim.log.levels.WARN] = "WARN",
    [vim.log.levels.ERROR] = "ERROR",
  }

  local function append_notify_log(msg, level)
    local line = string.format(
      "%s [%s] %s",
      os.date("%Y-%m-%d %H:%M:%S"),
      level_name[level] or tostring(level or "INFO"),
      tostring(msg):gsub("\n", " ")
    )
    pcall(vim.fn.writefile, { line }, notify_log, "a")
  end

  vim.notify = function(msg, level, opts)
    append_notify_log(msg, level)
    return original_notify(msg, level, opts)
  end

  vim.api.nvim_create_user_command("NotifyLog", function()
    vim.cmd("split " .. vim.fn.fnameescape(notify_log))
  end, { desc = "Open notification log" })

  vim.api.nvim_create_user_command("NotifyLogClear", function()
    pcall(vim.fn.writefile, {}, notify_log)
    original_notify("Notification log cleared", vim.log.levels.INFO)
  end, { desc = "Clear notification log" })

  local messages_log = vim.fn.stdpath("data") .. "/messages.log"
  vim.api.nvim_create_user_command("MessagesLog", function()
    local msgs = vim.fn.execute("messages")
    local lines = vim.split(msgs, "\n", { plain = true, trimempty = false })
    pcall(vim.fn.writefile, lines, messages_log)
    original_notify("Messages log saved", vim.log.levels.INFO)
  end, { desc = "Save :messages to file" })

  vim.api.nvim_create_user_command("MessagesLogOpen", function()
    vim.cmd("split " .. vim.fn.fnameescape(messages_log))
  end, { desc = "Open saved messages log" })

  vim.api.nvim_create_user_command("MessagesCopy", function()
    local msgs = vim.fn.execute("messages")
    vim.fn.setreg("+", msgs)
    original_notify("Copied :messages to clipboard", vim.log.levels.INFO)
  end, { desc = "Copy :messages to clipboard" })

  vim.api.nvim_create_user_command("LastErrorCopy", function()
    local msgs = vim.split(vim.fn.execute("messages"), "\n", { plain = true, trimempty = false })
    local picked = nil
    for i = #msgs, 1, -1 do
      local line = msgs[i]
      if line:find("Error", 1, true) or line:find("E%d+") or line:find("stack traceback", 1, true) then
        picked = line
        break
      end
    end

    if not picked then
      picked = msgs[#msgs] or "No error message found"
    end

    vim.fn.setreg("+", picked)
    original_notify("Copied last error line to clipboard", vim.log.levels.INFO)
  end, { desc = "Copy last error line" })
end

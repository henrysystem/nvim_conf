local M = {}
local redraw_timer

local function in_opencode()
  local ft = vim.bo.filetype
  return ft == "opencode_terminal" or ft == "opencode_ask"
end

local function look_horizontal()
  local col = vim.fn.virtcol(".")
  local width = math.max(vim.api.nvim_win_get_width(0), 1)
  local ratio = col / width

  if ratio < 0.33 then
    return "left"
  elseif ratio > 0.66 then
    return "right"
  end
  return "center"
end

local function blink_now()
  local t = vim.uv.now()
  return (math.floor(t / 220) % 29) == 0
end

function M.render()
  if blink_now() then
    return "(- -)"
  end

  local h = look_horizontal()
  local m = vim.api.nvim_get_mode().mode

  if in_opencode() then
    if h == "left" then
      return "(O .)"
    elseif h == "right" then
      return "(. O)"
    end
    return "(O O)"
  end

  if m:sub(1, 1) == "i" or m:sub(1, 1) == "r" then
    if h == "left" then
      return "(u .)"
    elseif h == "right" then
      return "(. u)"
    end
    return "(u u)"
  end

  if h == "left" then
    return "(o .)"
  elseif h == "right" then
    return "(. o)"
  end
  return "(o o)"
end

function M.setup()
  if redraw_timer or #vim.api.nvim_list_uis() == 0 then
    return
  end

  redraw_timer = vim.uv.new_timer()
  redraw_timer:start(
    0,
    280,
    vim.schedule_wrap(function()
      pcall(vim.cmd, "redrawstatus")
    end)
  )

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if redraw_timer then
        redraw_timer:stop()
        redraw_timer:close()
        redraw_timer = nil
      end
    end,
  })
end

return M

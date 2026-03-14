-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

if vim.fn.has("win32") == 1 then
  local path_sep = ";"

  local function prepend_path(path)
    if path == nil or path == "" then
      return
    end
    if vim.uv.fs_stat(path) == nil then
      return
    end
    local current_path = vim.env.PATH or ""
    if not string.find(path_sep .. current_path .. path_sep, path_sep .. path .. path_sep, 1, true) then
      vim.env.PATH = path .. path_sep .. current_path
    end
  end

  prepend_path(vim.fn.expand("~/AppData/Local/bin"))
  prepend_path(vim.fn.expand("~/AppData/Roaming/npm"))

  local winget_packages = vim.fn.expand("~/AppData/Local/Microsoft/WinGet/Packages")
  local winget_patterns = {
    "BrechtSanders.WinLibs.POSIX.UCRT_*/mingw64/bin",
    "BurntSushi.ripgrep.MSVC_*/ripgrep-*/",
    "ImageMagick.Q16_*/",
    "ImageMagick.ImageMagick_*/",
    "sharkdp.fd_*/fd-*/",
    "junegunn.fzf_*/",
    "JesseDuffield.lazygit_*/",
  }

  for _, pattern in ipairs(winget_patterns) do
    local matches = vim.fn.globpath(winget_packages, pattern, false, true)
    for _, match in ipairs(matches) do
      prepend_path(match)
    end
  end
end

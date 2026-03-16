return {
  "Gentleman-Programming/veil.nvim",
  event = "VeryLazy",
  config = function()
    require("veil").setup({
      -- Archivos donde se ocultan valores automáticamente
      files = {
        ".env",
        ".env.*",
        ".npmrc",
        ".pypirc",
        "credentials.json",
        "secrets.yaml",
        "secrets.yml",
        ".secrets",
        "opencode.json",  -- Agregar tu config de OpenCode
      },
      
      -- Patrones adicionales para tus archivos
      extra_patterns = {
        "GEMINI_API_KEY",
        "OPENAI_API_KEY",
        "ANTHROPIC_API_KEY",
        "DATABASE_URL",
        "DB_PASSWORD",
        "EMAIL_PASSWORD",
      },
      
      -- Ocultar con asteriscos
      conceal_char = "*",
      
      -- Atajos
      keymaps = {
        toggle = "<leader>sv",  -- Toggle veil
        peek = "<leader>sp",    -- Ver valor temporalmente
      },
    })
  end,
}

---
name: nvim-preflight-guard
description: >
  Pre-change safety checks for Neovim config edits.
  Trigger: Before editing keymaps, startup autocommands, dashboard, or OpenCode behavior.
metadata:
  scope: [root]
  auto_invoke: "Before any config edits under init.lua, lua/config, or lua/plugins"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

# nvim-preflight-guard

## Purpose
Prevent regressions when changing Neovim behavior by enforcing a short preflight checklist.

## Always
- Confirm active config path in-session: `:echo stdpath('config')`.
- Check mapping collisions before adding new leader mappings.
- Keep a fallback command path for critical actions (e.g., `:Proyecto`, `:Asistente`).
- Validate modified Lua files with headless startup after edits.

## Never
- Reuse a leader prefix already owned by another plugin without moving one side.
- Remove startup hooks without replacement for manual access.

## Preflight Checklist
1. Search existing mappings for target prefix (`<leader>o`, `<leader>a`, etc.).
2. Confirm plugin ownership of filetypes that affect behavior (`oil`, `opencode_terminal`, `opencode_ask`).
3. Edit config.
4. Run quick validation:
   - `nvim --headless "+lua pcall(require,'config.assistant')" +qa`
   - `nvim --headless "+doautocmd User VeryLazy" +qa`
5. Verify runtime mappings with `maparg` checks for changed keys.

## Output Standard
- Every user-visible action must include clear feedback and command trace where practical.

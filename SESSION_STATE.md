# 🧠 Session State

## 📅 Current Context
**Date:** 2026-02-23
**Focus:** Neovim productivity system (OpenCode + assistant + project launcher)

## 🚧 Active Tasks
- [x] Install full cognitive skills/bootstrap in project
- [x] Configure Engram integration for Codex/Gemini/OpenCode/Claude
- [x] Persist key learnings and decisions in Engram memory
- [ ] Optional: refine multi-OpenCode layout rules for edge cases

## 📝 Recent Notes
- Added command-driven assistant (`:Asistente`, `:Do`) in Spanish with grouped categories.
- Added project startup picker (Dynasif, Trading, Proyectos) and manual reopen via `:Proyecto` / `<leader>ap`.
- OpenCode windows can now be launched independently via `termopen("opencode", { cwd = ... })`.
- Added visual labels for OpenCode directory context in each window (`winbar`).

## 📂 Key Files
- `init.lua`
- `lua/config/assistant.lua`
- `lua/config/keymaps.lua`
- `lua/plugins/opencode.lua`
- `lua/plugins/ui.lua`

## ⚙️ Configuration
- **Project**: `nvim`
- **Skills Bootstrap**: `v7.2.3` (Generic Core)
- **Engram**: configured for Codex, Gemini CLI, OpenCode, Claude Code

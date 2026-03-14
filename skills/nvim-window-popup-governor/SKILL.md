---
name: nvim-window-popup-governor
description: >
  Guardrails for creating windows, splits, floating popups, and OpenCode panes in a predictable way.
  Trigger: When adding or modifying any command that opens windows/popups or changes pane layout.
metadata:
  author: nvim-local
  version: "1.0"
---

## When to Use
- Any change under `lua/config/assistant.lua` related to:
  - `abrir nueva ventana ...`
  - split direction prompts
  - floating windows (Engram, file preview, helpers)
  - OpenCode multi-window context behavior

## Core Rules

### ALWAYS
- Ask for directory first when opening tree/OpenCode in a new window.
- Ask for position second (`Arriba` default), and include `"<- Volver"` to return to previous step.
- Use explicit split commands (`aboveleft split`, `belowright split`, `topleft vsplit`, `botright vsplit`).
- For OpenCode per-project panes, spawn independent terminal with cwd:
  - `termopen("opencode", { cwd = <dir> })`
- Label OpenCode panes with visible directory context in `winbar`.
- Show command trace in notifications (`[comando: ...]`).

### NEVER
- Reuse an existing OpenCode buffer when user requested a new OpenCode window/context.
- Include OpenCode panes as candidates for context source selection.
- Create duplicate context options for the same directory.

## Standard UX Patterns
- **Two-step flows**: directory -> position.
- **Default behavior**: if position dialog closes, use `Arriba`.
- **Menu text style**: infinitive commands (`abrir`, `mover`, `crear`, `borrar`, `copiar`).
- **Grouped menus**: `OPCION ABRIR/MOVER/CREAR/BORRAR/COPIAR/OTROS`.

## Popup Conventions
- Centered floating window.
- Rounded border.
- `q` closes the popup.
- Use read-only scratch buffer where appropriate.

## Regression Checklist
1. `:do abrir nueva ventana con arbol` asks for folder and then position.
2. `:do abrir nueva ventana con opencode` asks for source context and position.
3. OpenCode shows directory label in each pane.
4. Context list excludes OpenCode panes and has no duplicated directories.
5. `:do` menu still shows grouped categories and command preview.

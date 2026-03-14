---
name: assistant-command-patterns
description: >
  Command taxonomy and parsing patterns for :Asistente / :Do.
  Trigger: When adding new assistant intents, menu items, or command categories.
metadata:
  scope: [root]
  auto_invoke: "When extending assistant commands or menu structure"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

# assistant-command-patterns

## Purpose
Keep assistant commands predictable, grouped, and easy to execute.

## Categories (required)
- ABRIR
- MOVER
- CREAR
- BORRAR
- COPIAR
- OTROS

## Rules
- Every suggestion must include a category.
- Menu should display grouped headers and bullet options.
- Keep command preview explicit (`-> [<command>]`).
- Prefer direct key hints for movement actions (`<C-w>h`, `<C-w>L`, etc.).

## Intent Design
- Add at least one strict pattern and one tolerant pattern (synonym/typo).
- For destructive actions, enforce confirmation.
- For ambiguous input, show one-line examples.

## Regression Checks
1. `:Asistente` opens grouped list.
2. Header selection is non-executable and informative.
3. Bullet selection executes intended action.
4. `:do ...` abbreviation routes to `:Do ...`.

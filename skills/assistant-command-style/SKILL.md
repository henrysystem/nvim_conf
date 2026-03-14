---
name: assistant-command-style
description: >
  Style and parsing standard for :Asistente/:Do commands.
  Trigger: When adding, renaming, grouping, or parsing assistant commands.
metadata:
  author: nvim-local
  version: "1.0"
---

## When to Use
- Any edit to command suggestions, menu labels, aliases, or parser patterns in `lua/config/assistant.lua`.

## Core Rules

### ALWAYS
- Keep visible commands in infinitive form:
  - `abrir`, `mover`, `crear`, `borrar`, `copiar`, `ver`, `buscar`.
- Keep categories stable and ordered:
  - `ABRIR`, `MOVER`, `CREAR`, `BORRAR`, `COPIAR`, `OTROS`.
- Keep command preview visible as `-> [<comando>]`.
- Keep command feedback trace in notifications: `[comando: ...]`.
- Maintain concise aliases for speed:
  - `mw` (mover ventana),
  - `pc` (mover cursor),
  - `engram e/c/b`.

### NEVER
- Expose duplicated menu entries with same intent under different wording.
- Mix imperative and infinitive in visible menu labels.
- Remove alias compatibility without adding migration path.

## Parsing Compatibility
- Visible command can be strict infinitive (`mover ventana a la derecha`).
- Parser should accept natural variants (`mueve la ventana a la derecha`) but normalize behavior.
- For ambiguous input, return short guidance with 2-3 valid examples.

## Menu Standard
- Header rows are non-executable.
- Action rows use bullet format.
- Keep quick templates section at top for most frequent actions.

## Regression Checklist
1. `:Do` opens grouped categories with no duplicate visible intents.
2. Selecting a bullet executes command; selecting header does not.
3. `mover ...` and tolerated natural variants map to same behavior.
4. `engram e/c/b` still works.
5. `:do` abbreviation still expands to `:Do`.

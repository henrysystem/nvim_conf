---
name: task-close-cleanup
description: >
  End-of-task cleanup checklist for Neovim assistant changes.
  Trigger: When a requested task is completed and before final handoff.
metadata:
  author: nvim-local
  version: "1.0"
---

## When to Use
- After implementing any assistant/menu/window behavior change.

## Checklist
1. Remove dead commands from parser and suggestions.
2. Remove duplicate visible entries in menu categories.
3. Keep visible command wording in infinitive form.
4. Run headless validation:
   - `nvim --headless "+lua local ok,err=pcall(require,'config.assistant'); if not ok then error(err) end" +qa`
5. Verify changed key paths still reachable (`:Do`, `:Proyecto`, startup flow).
6. Update memory note if behavior changed significantly.

## Output Rule
- Final message must include:
  - what was cleaned,
  - which legacy paths were removed,
  - what remains intentionally for compatibility.

---
name: opencode-context-guard
description: >
  Rules for OpenCode window/session context to avoid writing in wrong project.
  Trigger: When creating OpenCode windows, changing cwd, or running multi-window OpenCode workflows.
metadata:
  scope: [root]
  auto_invoke: "When user asks for new OpenCode window/session/context"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

# opencode-context-guard

## Purpose
Ensure OpenCode instances are attached to the intended directory and clearly labeled.

## Always
- Ask/select directory source before spawning new OpenCode terminal instance.
- Set local directory for the target window (`lcd`) before terminal launch.
- Label OpenCode windows with visible context (winbar: `OpenCode @ <dir>`).
- Exclude existing OpenCode windows from context source choices.

## Never
- Reuse existing OpenCode buffer when user explicitly requested a new context.
- Infer context from previous session silently.

## Recommended Flow
1. Collect candidate contexts from non-OpenCode windows.
2. Deduplicate by normalized directory.
3. Ask user for position (default: top).
4. Split from selected source window.
5. `lcd <dir>` in new window.
6. `termopen('opencode', { cwd = <dir> })`.
7. Apply/refresh winbar label.

## Verification
- Open two OpenCode windows from different directories.
- Confirm each shows different winbar path.
- Confirm command output logs selected split + cwd.

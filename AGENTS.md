# [Project Name] - Project Guidelines

## Project Overview
[Insert brief project description here]

### Tech Stack
- **Language**: [e.g. Python, Java, PowerBuilder]
- **Database**: [e.g. PostgreSQL, Oracle]
- **Framework**: [e.g. React, FastAPI]
- **AI Assistants**: Claude Code, Gemini CLI, Codex

---

## Intent Classifier (Read First)

Before loading any skill, classify the request by level.
Full rules: [policies/token-optimization.md](policies/token-optimization.md)
Classifier is a default guide, not a hard restriction; escalate when risk or uncertainty is high.

| Level | When | Skills | Subagent |
|-------|------|--------|----------|
| TRIVIAL | User says where + cosmetic/property change | 0 | No |
| MEDIUM | Logic in 1 object, user says where | 1 max | No |
| COMPLEX | Unknown where, multi-object, new flow | explore + 1 | Yes |
| AMBIGUOUS | Cannot classify | Ask user | No |

---

## Skill Auto-invocation (Strict Cues)

Use these cues to load exactly one relevant skill first, then expand only if needed.

- `trading/strategy-creation`: when user asks to create/refactor a strategy, or editing `src/strategies/**/*.py` (except `indicators/`)
- `trading/concepts-smc`: BOS, CHoCH, Order Block, FVG, imbalance, liquidity sweep, inducement
- `trading/concepts-indicators`: RSI, MACD, Volume Profile, candle patterns, divergence
- `trading/concepts-risk`: lot size, position sizing, SL/TP risk, daily loss limits, drawdown, R-multiples
- `trading/concepts-structure`: HH/HL, LH/LL, swing points, trend bias, multi-timeframe, sessions
- `trading/backtesting`: backtest, expectancy, win rate, walk-forward, out-of-sample, curve fitting
- `trading/mt5`: `MetaTrader5`, `mt5.initialize`, order_send, broker integration, retcodes
- `nvim-window-popup-governor`: creating/modifying split windows, floating popups, OpenCode pane context
- `assistant-command-style`: changing :Asistente/:Do menu wording, aliases, parser patterns, or categories
- `task-close-cleanup`: finishing a task that modified assistant commands/windows/popups; run cleanup checklist

---

## Available Skills

| Skill | Description |
|-------|-------------|
| `git-workflow` | Branches, merging, conflicts |
| `project-workflow` | History, documentation, session state |
| `sdd-explore` | Codebase exploration (complex tasks only) |
| `sdd-propose` | Proposal phase |
| `sdd-design` | Technical design |
| `sdd-apply` | Implementation phase |
| `sdd-verify` | Verification gate |
| `sdd-release` | Release and documentation |
| `search-changes` | Search previous changes |
| `memory-protocol` | Persistent memory (Engram) |
| `chore-cleanup` | Safe cleanup temp artifacts |
| `chore-archive` | Archive deliverables |
| `model-routing` | Multi-model orchestration |
| `ai-bootstrap` | Install/update AI structure |
| `nvim-window-popup-governor` | Rules for splits/popups/OpenCode window context |
| `assistant-command-style` | Standards for assistant command wording/parsing/menu consistency |
| `task-close-cleanup` | End-of-task cleanup checklist for assistant/menu/window changes |

Trading domain skills:
- `trading/strategy-creation` | Standard template & rules for creating new strategies
- `trading/concepts-smc` | Smart Money Concepts: BOS, CHoCH, OB, FVG, Liquidity
- `trading/concepts-indicators` | RSI, MACD, Volume Profile, Candle Patterns usage
- `trading/concepts-risk` | Position sizing, daily limits, R:R, drawdown control
- `trading/concepts-structure` | Market structure, MTF analysis, sessions
- `trading/backtesting` | Backtest metrics, validation, walk-forward rules
- `trading/mt5` | MetaTrader 5 API: connection, orders, error handling

Python stack skills:
- `general` | Python best practices: typing, PEP8, venvs
- `pandas` | Efficient data manipulation with Pandas
- `python/tkinter` | Tkinter GUI: threading, layout, separation
- `sql-best-practices` | Universal SQL: normalization, indexing, formatting

Legacy PowerBuilder/Oracle skills (from installer):
- `config-ini` | `dynasif.ini` presets and DB target context

---

## Commit Format

```text
<type>: <description>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
